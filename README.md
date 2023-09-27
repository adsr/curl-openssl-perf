# curl-openssl-perf

An investigation of the performance regression we noticed when upgrading from
OpenSSL v1.1.1w to v3.0.2, mainly via curl.

### Notes

* This repo is optimized for step debugging different versions of OpenSSL
  simultaneously, hence the multiple submodules at different versions.
* Build deps required for curl and OpenSSL are not included here.
* Our use case is single-threaded, so we're only measuring and testing such.
* A test cert is included for convenience.

### Demo

```
$ # Compile OpenSSL, curl (HEAD), curl-test at v1.1.1w, v3.0.2, v3.1.3
$ ./compile.sh
...
$ 
$ # Ensure test programs are linked properly
$ ldd curl-test-openssl* | grep -e curl-test-openssl -e libcurl -e libcrypto
curl-test-opensslv111w:
    libcurl.so.4 => /home/adam/curl-openssl-perf/install-curl-opensslv111w/lib/libcurl.so.4 (0x00007f353aa20000)
    libcrypto.so.1.1 => /home/adam/curl-openssl-perf/install-opensslv111w/lib/libcrypto.so.1.1 (0x00007f353a400000)
curl-test-opensslv302:
    libcurl.so.4 => /home/adam/curl-openssl-perf/install-curl-opensslv302/lib/libcurl.so.4 (0x00007f1a5bb4b000)
    libcrypto.so.3 => /home/adam/curl-openssl-perf/install-opensslv302/lib/libcrypto.so.3 (0x00007f1a5b200000)
curl-test-opensslv313:
    libcurl.so.4 => /home/adam/curl-openssl-perf/install-curl-opensslv313/lib/libcurl.so.4 (0x00007f1ae3d1e000)
    libcrypto.so.3 => /home/adam/curl-openssl-perf/install-opensslv313/lib/libcrypto.so.3 (0x00007f1ae3400000)
$ 
$ # Start simple httpd
$ ./httpd.sh &
[1] 2791487
$ 
$ # Run test programs
$ ./curl-test-opensslv111w 30 | tee >(cut -d' ' -f2 | descstat pretransfer) >(cut -d' ' -f1 | descstat ______total) | cat
0.0504270 0.0084580
0.0556320 0.0116330
0.0637960 0.0194580
0.0637410 0.0196290
0.0637390 0.0195760
0.0556930 0.0116120
0.0597930 0.0191160
0.0597400 0.0189390
0.0637730 0.0208000
0.0597700 0.0191660
0.0597360 0.0189990
0.0637570 0.0191210
0.0637570 0.0192750
0.0676990 0.0193090
0.0637260 0.0195690
0.0637660 0.0198740
0.0636830 0.0192150
0.0557130 0.0114920
0.0597700 0.0191520
0.0637270 0.0191080
0.0637080 0.0195310
0.0597760 0.0190440
0.0637110 0.0193940
0.0637850 0.0198100
0.0636630 0.0195210
0.0597110 0.0190620
0.0637250 0.0192510
0.0598120 0.0190200
0.0637170 0.0196070
0.0557290 0.0113820
______total: n=30 min=0.050 max=0.068 mean=0.061 median=0.064 p95=0.064 p99=0.064 stdev=0.004 sum=1.839
pretransfer: n=30 min=0.008 max=0.021 mean=0.018 median=0.019 p95=0.020 p99=0.020 stdev=0.003 sum=0.539
$ ./curl-test-opensslv302 30 | tee >(cut -d' ' -f2 | descstat pretransfer) >(cut -d' ' -f1 | descstat ______total) | cat
0.0546710 0.0138870
0.0596690 0.0155460
0.0637430 0.0225710
0.0717300 0.0309830
0.0717270 0.0297990
0.0717350 0.0309960
0.0715420 0.0309340
0.0758620 0.0319520
0.0717380 0.0297390
0.0757110 0.0314220
0.0756970 0.0312450
0.0717350 0.0309260
0.0717350 0.0306430
0.0756290 0.0311530
0.0717310 0.0310230
0.0716760 0.0307870
0.0717420 0.0306390
0.0716650 0.0308620
0.0716730 0.0305630
0.0718310 0.0304160
0.0716660 0.0303250
0.0717560 0.0304360
0.0718260 0.0293320
0.0716320 0.0305980
0.0717160 0.0303230
0.0757150 0.0311390
0.0717130 0.0305160
0.0756640 0.0317180
0.0756580 0.0312780
0.0757600 0.0316260
______total: n=30 min=0.055 max=0.076 mean=0.072 median=0.072 p95=0.076 p99=0.076 stdev=0.005 sum=2.146
pretransfer: n=30 min=0.014 max=0.032 mean=0.029 median=0.031 p95=0.032 p99=0.032 stdev=0.004 sum=0.883
$ ./curl-test-opensslv313 30 | tee >(cut -d' ' -f2 | descstat pretransfer) >(cut -d' ' -f1 | descstat ______total) | cat
0.0580230 0.0170500
0.0556350 0.0119370
0.0636670 0.0201160
0.0636500 0.0205430
0.0598250 0.0117070
0.0636560 0.0200220
0.0637360 0.0200840
0.0636840 0.0198300
0.0637490 0.0195250
0.0636550 0.0195450
0.0637520 0.0204030
0.0516030 0.0111920
0.0637700 0.0199610
0.0677220 0.0195340
0.0636750 0.0199290
0.0636780 0.0199180
0.0636770 0.0198130
0.0596810 0.0182130
0.0637540 0.0196090
0.0637290 0.0196550
0.0636790 0.0200690
0.0637010 0.0201600
0.0637170 0.0200610
0.0637050 0.0199020
0.0637230 0.0197060
0.0637170 0.0198060
0.0636800 0.0196640
0.0636570 0.0200040
0.0637850 0.0197620
0.0676740 0.0205340
______total: n=30 min=0.052 max=0.068 mean=0.063 median=0.064 p95=0.064 p99=0.068 stdev=0.003 sum=1.885
pretransfer: n=30 min=0.011 max=0.021 mean=0.019 median=0.020 p95=0.020 p99=0.021 stdev=0.003 sum=0.568
```

### Analysis

Median pretransfer time (`CURLINFO_PRETRANSFER_TIME`) on v3.0.2 is ~10ms slower
than v1.1.1w -- (31 vs 19ms). v3.1.3 appears to have fixed this issue, being
just a smidge slower overall.

Taking a `perf record` while running `./curl-test-opensslv302 9999` shows the
big slow down is in libcrypto's `sa_doall` which is used to map various
functions against large arrays:

```
Samples: 38K of event 'cycles', Event count (approx.): 10745290398
  Children      Self  Command          Shared Object                       Symbol
...
+    9.77%     0.00%  swapper          [kernel.kallsyms]                   [k] cpuidle_enter          ◆
+    9.77%     0.18%  swapper          [kernel.kallsyms]                   [k] cpuidle_enter_state    ▒
+    9.66%     0.01%  curl-test-opens  libcrypto.so.3                      [.] construct_evp_method   ▒
+    9.32%     0.00%  curl-test-opens  libssl.so.3                         [.] ossl_statem_connect    ▒
+    9.31%     0.00%  curl-test-opens  libssl.so.3                         [.] state_machine          ▒
+    9.10%     0.00%  curl-test-opens  libcurl.so.4.8.0                    [.] ossl_connect_step2     ▒
+    9.09%     0.00%  curl-test-opens  libssl.so.3                         [.] SSL_connect            ▒
+    9.09%     0.00%  curl-test-opens  libssl.so.3                         [.] SSL_do_handshake       ▒
+    7.67%     0.00%  curl-test-opens  libssl.so.3                         [.] read_state_machine     ▒
+    7.22%     0.00%  curl-test-opens  libcrypto.so.3                      [.] ossl_sa_ALGORITHM_doall▒
+    7.22%     0.00%  curl-test-opens  libcrypto.so.3                      [.] ossl_sa_doall_arg      ▒
-    7.21%     6.15%  curl-test-opens  libcrypto.so.3                      [.] sa_doall               ▒
   - 6.15% __libc_start_call_main                                                                     ▒
        main                                                                                          ▒
        curl_easy_perform                                                                             ▒
        easy_perform                                                                                  ▒
        easy_transfer                                                                                 ▒
        curl_multi_perform                                                                            ▒
        multi_runsingle                                                                               ▒
        Curl_conn_connect                                                                             ▒
        cf_hc_connect                                                                                 ▒
        cf_hc_baller_connect                                                                          ▒
        Curl_conn_cf_connect                                                                          ▒
        cf_setup_connect                                                                              ▒
        Curl_conn_cf_connect                                                                          ▒
        ssl_cf_connect                                                                                ▒
        ssl_connect_nonblocking                                                                       ▒
        ossl_connect_nonblocking                                                                      ▒
      - ossl_connect_common                                                                           ▒
         - 3.82% ossl_connect_step1                                                                   ▒
              SSL_CTX_new                                                                             ▒
              SSL_CTX_new_ex                                                                          ▒
            + ssl_load_ciphers                                                                        ▒
         - 2.33% ossl_connect_step2                                                                   ▒
              SSL_connect                                                                             ▒
              SSL_do_handshake                                                                        ▒
              ossl_statem_connect                                                                     ▒
              state_machine                                                                           ▒
            - read_state_machine                                                                      ▒
               - 1.73% ossl_statem_client_process_message                                             ▒
                  + 0.61% tls_process_server_certificate                                              ▒
                  + 0.56% tls_process_server_hello                                                    ▒
                  + 0.55% tls_process_cert_verify                                                     ▒
               + 0.60% tls_get_message_header                                                         ▒
   - 1.06% sa_doall                                                                                   ▒
      - 0.71% impl_cache_flush_one_alg                                                                ▒
         - 0.65% lh_QUERY_doall_IMPL_CACHE_FLUSH                                                      ▒
            - OPENSSL_LH_doall_arg                                                                    ▒
                 doall_util_fn                                                                        ▒
+    6.18%     0.14%  curl-test-opens  libcrypto.so.3                      [.] evp_cipher_from_algorit▒
+    6.16%     0.01%  curl-test-opens  libcrypto.so.3                      [.] evp_names_do_all       ▒
+    6.00%     0.01%  curl-test-opens  libcrypto.so.3                      [.] ossl_namemap_doall_name▒
+    5.71%     0.00%  curl-test-opens  libcrypto.so.3                      [.] ossl_method_store_cache▒
+    5.68%     0.00%  curl-test-opens  libcrypto.so.3                      [.] ossl_method_cache_flush▒
...
```

Re-using `SSL_CTX` across HTTPS requests avoids some but not all of these
expensive calls. A quick and dirty (and likely broken) curl patch is included
which demonstrates this. The patched version is still about ~5ms slower than
v1.1.1w.

### Recommendation

For our use case, upgrading to v3.1.3 seems like a sensible option. According to
[OpenSSL's versioning policy][1], it should be ABI compatible with v3.0.2.

[1]: https://www.openssl.org/policies/general/versioning-policy.html
