#include <stdlib.h>
#include <stdio.h>
#include <curl/curl.h>

int main(int argc, char **argv) {
    CURLcode res;

    curl_global_init(CURL_GLOBAL_DEFAULT);

    int n = argc >= 2 ? atoi(argv[1]) : 1;
    int i;

    for (i = 0; i < n; i++) {
        CURL *curl = curl_easy_init();
        curl_easy_setopt(curl, CURLOPT_URL, "https://localhost:8181/");
        curl_easy_setopt(curl, CURLOPT_CAINFO, "./cert/test.crt");
        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
            break;
        }
        curl_easy_cleanup(curl);
    }

    curl_global_cleanup();

    return 0;
}
