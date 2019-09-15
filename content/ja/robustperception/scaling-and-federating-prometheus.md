- Prometheusドキュメント

*このページは[Prometheus公式ドキュメント和訳+α](http://it-engineer.hateblo.jp/entry/2019/01/20/085440)の一部です。*

# Scaling and Federating Prometheus

A single Prometheus server can easily handle millions of time series. That's enough for a thousand servers with a thousand time series each scraped every 10 seconds. As your systems scale beyond that, Prometheus can scale too.
Prometheusサーバー1つで何百万の時系列を簡単に処理できる。
これで10秒ごとにスクレイプされる1000時系列を持つ1000台のサーバーに対して十分である。
自分のシステムがこれを超えてスケールする時には、Prometheusもスケールすることが可能である。

<!-- ## Initial Deployment -->
## 最初のデプロイ
When starting out it's best to keep things simple. A single Prometheus server per datacenter or similar failure domain (e.g. EC2 region) can typically handle a thousand servers, so should last you for a good while. Running one per datacenter avoids having the internet or WAN links on the critical path of your monitoring.
開始時点では、物事はシンプルに保った方が良い。
典型的には、データセンターまたは類似の障害ドメイン（例えばEC2リージョン）につき1つのPrometheusサーバーで1000台のサーバーを処理できるので、かなり長い期間もつはずである。
データセンターにつき1つのPrometheusを稼働させることで、監視の重要なパスにインターネットやWANを挟むことが避けられる。

If you've more than one datacenter, you may wish to have global aggregates of some time series. This is done with a "global Prometheus" server, which federates from the datacenter Prometheus servers.
複数のデータセンターがあるなら、いくつかの時系列のグローバルな集計が欲しくなるかもしれない。
グローバルPrometheusサーバーがデーターセンターPrometheusサーバーからfederateすることで、これができる。
```
- scrape_config:
  - job_name: dc_prometheus
    honor_labels: true
    metrics_path: /federate
    params:
      match[]:
        - '{__name__=~"^job:.*"}'   # Request all job-level time series
    static_configs:
      - targets:
        - dc1-prometheus:9090
        - dc2-prometheus:9090
```

It's suggested to run two global Prometheis in different datacenters. This keeps your global monitoring working even if one datacenter has an outage.
グローバルPrometheusを2つ、異なるデータセンターで稼働させた方よい。
これでデーターセンターが1つ停止しても、グローバルなモニタリングは継続される。



# 参考リンク

- [Scaling and Federating Prometheus – Robust Perception | Prometheus Monitoring Experts](https://www.robustperception.io/scaling-and-federating-prometheus)

# 和訳活動の支援

Prometheusドキュメント和訳が役に立った方は、以下QRコードからPayPayで活動を支援して頂けるとありがたいです。

<figure class="figure-image figure-image-fotolife" title="上のQRコードからPayPayによる支援">[f:id:knj4484:20190127162659j:plain:w150:alt=PayPayによる支援用QRコード]<figcaption>上のQRコードからPayPayによる支援</figcaption></figure>

[asin:4873118778:detail]
[asin:4873118646:detail]
[asin:4873117917:detail]
