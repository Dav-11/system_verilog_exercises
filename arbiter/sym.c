# include <stdio.h>

# define num_master 4

int main() {
    int pri[num_master] = {0, 0, 1, 0};
    int req[num_master] = {0, 1, 1, 0};
    int grant[num_master] = {0, 1, 0, 0};

    int _pri_ext[2 * num_master];
    int _found[num_master] = {0, 0, 0, 0};
    int _skip[num_master] = {0, 0, 0, 0};

    // init var

    for (int i = 0; i < num_master; i++) {
        _pri_ext[i] = pri[i];
        _pri_ext[i + num_master] = pri[i];
    }

    printf("_pri_ext: [");
    for (int i = 0; i < 8; i++) {
        printf("%d ", _pri_ext[i]);
    }
    printf("]\n");


    // spec


    for (int i = 0; i < num_master; i++) {

        _found[i] = 0;
        _skip[i] = 0;

        // req1: request exists
        if (req[i]) {

            //
            // req2: No request from blocking
            //

            // if i has max prio => leave skip to 0

            // else
            if (!pri[i]) {

                // check if any other element has higher prio + req
                for (int j = 1; j < num_master; j++) {

                    if (!_skip[i]) {

                        // if has req and (the max prio elem is between i and j or the max prio elem is j)
                        if (req[j] && (_found[i] || _pri_ext[j + i])) {

                            printf("[i: %d, j:%d, req[i]: %d, found: %d, _pri_ext[j]: %d]\n", i, j, req[i], _found[i],
                                   _pri_ext[j]);

                            // found req w/ higher prio => skip i
                            _skip[i] = 1;
                        }

                        if (_pri_ext[j + i]) {
                            _found[i] = 1;
                        }
                    }
                }
            }
        }

        if (req[i]) {

            if (!_skip[i]) {
                grant[i] = 1;
            } else {
                grant[i] = 0;
            }
        } else {
            grant[i] = 0;
        }
    }

    printf("skip: [");
    for (int i = 0; i < num_master; i++) {
        printf("%d ", _skip[i]);
    }
    printf("]\n");

    printf("found: [");
    for (int i = 0; i < num_master; i++) {
        printf("%d ", _found[i]);
    }
    printf("]\n");

    printf("grant: [");
    for (int i = 0; i < num_master; i++) {
        printf("%d ", grant[i]);
    }
    printf("]\n");
}