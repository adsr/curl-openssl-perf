#include <stdlib.h>
#include <stdio.h>
#include <curl/curl.h>


static size_t cb(char *ptr, size_t size, size_t nmemb, void *userdata) {
    return size * nmemb;
}

int main(int argc, char **argv) {
    CURLcode res;

    curl_global_init(CURL_GLOBAL_DEFAULT);

    int n = argc >= 2 ? atoi(argv[1]) : 1;
    int i;

    for (i = 0; i < n; i++) {
        CURL *curl = curl_easy_init();
        curl_easy_setopt(curl, CURLOPT_URL, "https://localhost:8181/");
        curl_easy_setopt(curl, CURLOPT_CAINFO, "./cert/test.crt");
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb);
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
            break;
        }
        double t_total, t_pretransfer;
        curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &t_total);
        curl_easy_getinfo(curl, CURLINFO_PRETRANSFER_TIME, &t_pretransfer);
        curl_easy_cleanup(curl);
        printf("%.7f %.7f\n", t_total, t_pretransfer);
    }

    curl_global_cleanup();

    return 0;
}
