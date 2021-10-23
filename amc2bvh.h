#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "hashmap.h"
#include "matrices.h"

#define CHANNEL_COUNT 8

enum channel {
    CHANNEL_TX,
    CHANNEL_TY,
    CHANNEL_TZ,
    CHANNEL_RX,
    CHANNEL_RY,
    CHANNEL_RZ,
    CHANNEL_L,
    CHANNEL_EMPTY
};

struct jointmap_item {
    char *name;
    void *joint;
};

struct amc_joint {
    char *name;     // a unique name (from the ASF file)
    struct amc_joint **children;    // the children of the joint in the tree
    unsigned child_count;   // the number of children in the tree
    unsigned motion_index;  // where motion data for this joint should be stored in a sample (arguably doesn't belong here, but simplifies things)
    struct vec3 direction;  // the direction of the joint (from the ASF file)
    enum channel channels[CHANNEL_COUNT]; // the animation channels (from the ASF file)
    float length; // the length of the joint (from the ASF file)
};

struct amc_skeleton {
    struct hashmap *map;    // maps joint names to joints
    struct amc_joint *root; // the root of the joint tree
    struct vec3 root_position;  // the position of the root (from the ASF file)
};

// struct bvh_joint {
//     char *name;
//     struct joint *children[16];
//     struct vec3 offset;
//     unsigned char channels;
// };

struct amc_sample {
    struct amc_sample *next;
    float *data;
};

struct amc_motion {
    unsigned total_channels;
    unsigned sample_count;
    struct amc_sample *samples;
};

#define BUFFSIZE 2048

struct amc_skeleton *parse_asf_skeleton(FILE *asf, unsigned char max_child_count, bool verbose);
struct amc_motion *parse_amc_motion(FILE *amc, struct amc_skeleton *skeleton, bool verbose);
void write_bvh_skeleton(FILE *bvh, struct amc_skeleton *skeleton);
void write_bvh_joint(FILE *bvh,
                     struct amc_skeleton *skeleton,
                     struct amc_joint *joint,
                     struct vec3 offset,
                     int depth);

void parse_channel_order(enum channel *channels, char *str, int line_num);
struct vec3 parse_vec3(char *str, int line_num);

struct amc_skeleton *amc_skeleton_new(unsigned char max_child_count);
void amc_skeleton_free(struct amc_skeleton *skeleton);
struct amc_joint *amc_joint_new(unsigned char max_child_count);
void amc_joint_free(struct amc_joint *joint, bool deep);
struct amc_motion *amc_motion_new(unsigned total_channels);
void amc_motion_free(struct amc_motion *motion);
struct amc_sample *amc_sample_new(unsigned total_channels);
unsigned compute_amc_joint_indices(struct amc_joint *joint, unsigned offset);

#define FAIL(...) do {                                                         \
    fprintf(stderr, "Error: " __VA_ARGS__);                                    \
    exit(1);                                                                   \
} while(0)

#define fprintf_indent(indent, f, ...) do {                                    \
    for (int ind = 0; ind < indent; ind++) fprintf(f, "\t");                   \
    fprintf(f, __VA_ARGS__);                                                   \
} while(0)

void *xmalloc(size_t size);
void *xcalloc(size_t num, size_t size);
void *xrealloc(void *mem, size_t size);
char *readline(char *str, int n, FILE *f);
char *trim(char *str);
char *bifurcate(char *str, char delim);
bool streq(char *str, char *str2);
bool starts_with(char *str, char *pref);

struct hashmap *jointmap_new(void);
void jointmap_free(struct hashmap *map);
void *jointmap_get(struct hashmap *map, char *name);
void jointmap_set(struct hashmap *map, char *name, void *joint);
int jointmap_cmp(const void *a, const void *b, void *data);
uint64_t jointmap_hash(const void *item, uint64_t seed0, uint64_t seed1);
