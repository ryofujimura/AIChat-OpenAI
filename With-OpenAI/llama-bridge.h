#ifndef llama_bridge_h
#define llama_bridge_h

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

// Forward declarations for llama.cpp types
typedef struct llama_model* llama_model_t;
typedef struct llama_context* llama_context_t;
typedef struct llama_vocab* llama_vocab_t;
typedef struct llama_batch* llama_batch_t;
typedef struct llama_sampler* llama_sampler_t;
typedef struct llama_token_data* llama_token_data_t;
typedef struct llama_token_data_array* llama_token_data_array_t;

// Token type
typedef int32_t llama_token;

// Model parameters
typedef struct {
    uint32_t n_gpu_layers;
    uint32_t main_gpu;
    bool tensor_split;
    bool vocab_only;
    bool use_mmap;
    bool use_mlock;
} llama_model_params;

// Context parameters
typedef struct {
    uint32_t seed;
    uint32_t n_ctx;
    uint32_t n_batch;
    uint32_t n_threads;
    uint32_t n_threads_batch;
    uint8_t rope_scaling_type;
    float rope_freq_base;
    float rope_freq_scale;
    uint32_t mul_mat_q;
    uint32_t f16_kv;
    bool logits_all;
    bool embedding;
} llama_context_params;

// Token data
typedef struct {
    llama_token id;
    float logit;
    float p;
} llama_token_data;

// Token data array
typedef struct {
    llama_token_data* data;
    size_t size;
    bool sorted;
} llama_token_data_array;

// Function declarations
llama_model_params llama_model_default_params(void);
llama_context_params llama_context_default_params(void);

llama_model_t llama_load_model_from_file(const char* path, llama_model_params params);
void llama_free_model(llama_model_t model);

llama_context_t llama_new_context_with_model(llama_model_t model, llama_context_params params);
void llama_free(llama_context_t ctx);

llama_vocab_t llama_model_get_vocab(llama_model_t model);
uint32_t llama_vocab_n_tokens(llama_vocab_t vocab);
llama_token llama_vocab_eos(llama_vocab_t vocab);

int32_t llama_tokenize(llama_vocab_t vocab, const char* text, int32_t text_len, llama_token* tokens, int32_t n_max_tokens, bool add_bos, bool special);

llama_batch_t llama_batch_get_one(llama_token* tokens, int32_t n_tokens);
int32_t llama_decode(llama_context_t ctx, llama_batch_t batch);

float* llama_get_logits(llama_context_t ctx);

llama_sampler_t llama_sampler_init_top_k(uint32_t k);
llama_sampler_t llama_sampler_init_top_p(float p, uint32_t min_keep);
llama_sampler_t llama_sampler_init_temp(float temp);

void llama_sampler_apply(llama_sampler_t sampler, llama_token_data_array_t* candidates);
llama_token llama_sampler_sample(llama_sampler_t sampler, llama_context_t ctx, uint32_t min_p);

void llama_sampler_free(llama_sampler_t sampler);

int32_t llama_token_to_piece(llama_vocab_t vocab, llama_token token, char* buf, int32_t length, bool special, bool space);

#endif /* llama_bridge_h */ 