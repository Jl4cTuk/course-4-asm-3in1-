#include <stdio.h>

int main() {
    int n = 20, m = 4, min;
    // scanf("%d", &n);
    // scanf("%d", &m);
    printf("n = %d\nm = %d\n", n, m);

    min = m;
    if (m > n) {
        min = n;
    }

    for (int i = min; i < n*m; i+=min) {
        if (m % i == 0 && n % i == 0) {
            printf("подошло %d\n", i);
        }
        printf("не подошло %d\n", i);
    }

    return 0;
}
