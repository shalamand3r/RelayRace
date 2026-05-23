#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

int apply_coretrust_bypass_wrapper(const char *inputPath, const char *outputPath, char *teamID, char *appStoreBinary);

static char *arg_value(int argc, char **argv, const char *name) {
    for (int i = 1; i + 1 < argc; i++) {
        if (strcmp(argv[i], name) == 0) {
            return argv[i + 1];
        }
    }
    return NULL;
}

static bool has_arg(int argc, char **argv, const char *name) {
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], name) == 0) {
            return true;
        }
    }
    return false;
}

static int usage(const char *argv0) {
    fprintf(stderr, "Usage: %s -i input [-o output | -r] [-t teamID] [-A appStoreBinary]\n", argv0);
    return 2;
}

int main(int argc, char **argv) {
    char *input = arg_value(argc, argv, "-i");
    char *output = arg_value(argc, argv, "-o");
    char *teamID = arg_value(argc, argv, "-t");
    char *appStoreBinary = arg_value(argc, argv, "-A");
    bool replace = has_arg(argc, argv, "-r");

    if (!input) {
        return usage(argv[0]);
    }

    if (replace && output) {
        return usage(argv[0]);
    }

    if (replace) {
        output = input;
    }

    if (!output) {
        return usage(argv[0]);
    }

    struct stat st;
    if (stat(input, &st) != 0) {
        perror("stat input");
        return 1;
    }

    fprintf(stderr, "[relayrace-ct-bypass] input=%s output=%s\n", input, output);
    int rc = apply_coretrust_bypass_wrapper(input, output, teamID, appStoreBinary);
    fprintf(stderr, "[relayrace-ct-bypass] result=%d\n", rc);
    return rc == 0 ? 0 : 1;
}
