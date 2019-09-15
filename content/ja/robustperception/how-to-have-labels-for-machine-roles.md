- Prometheusドキュメント

*このページは[Prometheus公式ドキュメント和訳+α](http://it-engineer.hateblo.jp/entry/2019/01/20/085440)の一部です。*

<!-- # How to have labels for machine roles -->
# マシンロールのためのラベルはどう持つべきか？
<!-- It's a best practice with Prometheus that target labels should be constant over a target's entire lifetime. On the other hand it's useful to aggregate metrics across all the machines that are currently Apache servers. How can we do that? -->
ターゲットラベルがターゲットの生涯に渡って不変にすることが、Prometheusを使うときのベストプラクティスである。
他方で、Apacheサーバーであるマシンにまたがってメトリクスを集約すると便利である。
これをどうやってやるか？

<!-- A key concept in Prometheus is that you want continuity in your time series, that is that they don't change labels and become a different time series. Something like a Chef role which may change as the role of a machine changes isn't a good target label. Every time the roles changed there'd be discontinuities in the graphs and alerts would get reset. -->
Prometheusで鍵となる概念は、時系列の連続性が求められるということ、つまり、時系列のラベルが変わって別の時系列になってしまわないということである。
Chefのロールのようにマシンのロールが変わると変わってしまうものは、良いターゲットラベルではない。
ロールが変わるたびに、グラフが途切れてしまい、アラートはリセットされてしまう。

<!-- That means though that you can't easily aggregate metrics like CPU usage across machines in a role. The good news is that the textfile collector and grouping modifiers offer a way to do this. -->
だが、これは、あるロールを持つマシンにまたがってCPU利用率のようなメトリクスを集約できないということを意味する。
幸いなことに、これは、textfile collectorとグループ修飾子で出来る。

<!-- We'll start from scratch, download and run the node exporter with the textfile collector: -->
一から始めることにして、node exporterをダウンロードし、textfile collectorと共に実行する。
```
wget https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz
tar -xzf node_exporter-0.15.1.linux-amd64.tar.gz
cd node_exporter-*
mkdir textfile_collector
./node_exporter -collector.textfile.directory textfile_collector &
```

<!-- Let's say that this machine runs postfix and apache. We'll add a metric with these roles: -->
このマシンでpostfixとapacheを実行しているとする。
以下のように、それらのロールのメトリクスを追加する。
```
cat <<EOF > textfile_collector/roles.prom
machine_role{role="postfix"} 1
machine_role{role="apache"} 1
EOF
```

<!-- This would usually be done by your configuration management system. If you visit http://localhost:9100/metrics you'll see your new metrics. -->
これは、普通、設定管理システムで行われるだろう。
http://localhost:9100/metrics を見てみると、新しいメトリクスが見つかるだろう。

<!-- Next we'll quickly setup a Prometheus server to scrape this: -->
次に、これをスクレイプするためのPrometheusサーバーを手早く準備する。
```
wget https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz
tar -xzf prometheus-2.0.0.linux-amd64.tar.gz
cd prometheus-*
cat <<'EOF' > prometheus.yml
global:
  scrape_interval: 10s
  evaluation_interval: 10s
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets:
        - localhost:9100
EOF
./prometheus
```

<!-- If we wanted metrics for apache role with the role label attached, you can use group_left in the expression browser: -->
もし、roleラベルが付与されたapacheロールのメトリクスが必要な場合、expressionブラウザでgroup_leftを使うことができる。
```
up * on (instance, job) group_left(role) machine_role{role="apache"}
```

<!-- This can then be aggregated as normal: -->
こうすると普段通り集約できる。
```
sum by (job, role)(
    up * on (instance, job) group_left(role) machine_role{role="apache"}
)
```

<!-- This technique lets you have the benefits of attaching labels to your targets, without the downsides of having labels changing over the lifetime of the target. A similar approach works for applications too! -->
この手法で、ラベルをターゲットの生涯に渡って変更したときのような欠点を排して、ターゲットにラベルを付与する恩恵が得られる。
アプリケーションに対しても似たような方法で上手くいく。

# 参考リンク

- [How to have labels for machine roles – Robust Perception | Prometheus Monitoring Experts](https://www.robustperception.io/how-to-have-labels-for-machine-roles)

# 和訳活動の支援

Prometheusドキュメント和訳が役に立った方は、以下QRコードからPayPayで活動を支援して頂けるとありがたいです。

<figure class="figure-image figure-image-fotolife" title="上のQRコードからPayPayによる支援">[f:id:knj4484:20190127162659j:plain:w150:alt=PayPayによる支援用QRコード]<figcaption>上のQRコードからPayPayによる支援</figcaption></figure>

[asin:4873118778:detail]
[asin:4873118646:detail]
[asin:4873117917:detail]
