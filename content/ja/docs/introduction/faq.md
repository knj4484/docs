---
title: FAQ
sort_rank: 5
toc: full-width
---

# <span class="anchor-text-supplement">Frequently Asked Questions</span>よくある質問

## <span class="anchor-text-supplement">General</span>一般

### <span class="anchor-text-supplement">What is </span>Prometheusとは何か？

Prometheusは、活発なエコシステムを持つ、オープンソースのシステム監視およびアラートのツールキットである。
[概要](/ja/docs/introduction/overview/)を参照。


### <span class="anchor-text-supplement">How does </span>Prometheus<span class="anchor-text-supplement"> compare against other monitoring systems?</span>を他の監視システムと比較してどうか？

[比較](/ja/docs/introduction/comparison/)のページを参照。

### <span class="anchor-text-supplement">What dependencies does </span>Prometheus<span class="anchor-text-supplement"> have?</span>はどのような依存があるか？

Prometheusサーバーはスタンドアローンで稼働し、外部の依存はない。

### <span class="anchor-text-supplement">Can </span>Prometheus<span class="anchor-text-supplement"> be made highly available?</span>を高可用にすることはできるか？

はい。同一のPrometheusサーバーを2つ以上の別々のマシンで稼働させればよい。
同一のアラートは[Alertmanager](https://github.com/prometheus/alertmanager)が重複排除をする。

[Alertmanagerを高可用にする](https://github.com/prometheus/alertmanager#high-availability)には、[Mesh cluster](https://github.com/weaveworks/mesh)内で複数のインスタンスを実行し、Prometheusがそれぞれのインスタンスに通知を送信するように設定することができる。

### <span class="anchor-text-supplement">I was told </span>Prometheus<span class="anchor-text-supplement"> “doesn't scale”.</span>はスケールしないと言われました

実際には、Prometheusをスケールさせたり連合(federate)させる様々な方法がある。
Robust Perception blogの[Scaling and Federating Prometheus](https://www.robustperception.io/scaling-and-federating-prometheus/)を参照すること。

### <span class="anchor-text-supplement">What language is </span>Prometheus<span class="anchor-text-supplement"> written in?</span>はどの言語で書かれていますか？

PrometheusのほとんどのコンポーネントはGoで書かれている。
いくつかはJava、Python、Rubyでも書かれている。

### <span class="anchor-text-supplement">How stable are </span>Prometheus<span class="anchor-text-supplement"> features, storage formats, and </span>の機能やストレージの形式、API<span class="original-header">s</span>はどれぐらい安定していますか？

GitHubのPrometheusオーガニゼーションにあるバージョン1.0.0以上の全てのリポジトリは[セマンティック バージョニング](https://semver.org/lang/ja/)に従っている。
破壊的な変更は、メジャーバージョンのインクリメントで表される。
実験的なコンポーネントでは、例外がありうるが、アナウンスでその旨が明確に記される。

バージョン1.0.0にまだ達していないリポジトリでも、一般的に、かなり安定している。
各リポジトリで適切なリリースプロセスと1.0.0リリースを目指している。
破壊的な変更は何れにしてもリリースノートで示され（`[CHANGE]`と記される）、正式にリリースされていないコンポーネントに対しては、明確に伝えられる。

### <span class="anchor-text-supplement">Why do you pull rather than push?</span>なぜプッシュではなくプルなのか？

HTTPを通してpullすることには、たくさんの利点がある。

* 開発中に自分のラップトップから監視を実行できる
* 監視対象がダウンしていることがより簡単に分かる
* Webブラウザで監視対象を開き、手動でその状態を調べることができる

概して、pushよりもpullする方が少しだけ良いと信じているが、監視システムを検討する際の重要な点ではないであろう。

pushしなければならない場合のために、[Pushgateway](/ja/docs/instrumenting/pushing/)を提供している。

### <span class="anchor-text-supplement">How to feed logs into </span>どうやってPrometheusにログを取り込みますか？

短い答え：やらないで下さい。[ELK stack](https://www.elastic.co/jp/products/)のようなものを使うこと。

長い答え：Prometheusはメトリクスを集めて処理するシステムであって、イベントロギングシステムではない。
Raintankのブログ記事[Logs and Metrics and Graphs, Oh My!](https://blog.raintank.io/logs-and-metrics-and-graphs-oh-my/)で、ログとメトリクスの違いについて詳細が説明されている。

アプリケーションのログからPrometheusのメトリクスを抽出したい場合は、Googleの[mtail](https://github.com/google/mtail)が役に立つであろう。

### <span class="anchor-text-supplement">Who wrote </span>誰がPrometheusを書きましたか？

Prometheusは、最初は、[Matt T. Proud](http://www.matttproud.com)と[Julius Volz](http://juliusv.com)によって個人的に始められた。
初期の開発の大部分は[SoundCloud](https://soundcloud.com)に支援されていた。

今は、幅広い企業や個人によって保守・拡張されている。

### <span class="anchor-text-supplement">What license is </span>どのようなライセンスの下でPrometheus<span class="anchor-text-supplement"> released under?</span>はリリースされていますか？

Prometheusは[Apache 2.0](https://github.com/prometheus/prometheus/blob/master/LICENSE)ライセンスの下でリリースされている。

### <span class="anchor-text-supplement">What is the plural of </span>Prometheusの複数形は？

[広範囲の調査](https://youtu.be/B_CDeYrqxjQ)の後で、正しいPrometheusの複数形はPrometheisであると確定した。

### <span class="anchor-text-supplement">Can I reload </span>Prometheus<span class="anchor-text-supplement">'s configuration?</span>の設定をリロードすることはできますか？

はい、Prometheusのプロセスに`SIGHUP`を送るか、エンドポイント`/-/reload`にHTTP POSTリクエスト送ると、設定ファイルをリロードして適用します。
様々なコンポーネントが、変更の失敗をうまく扱うように試みます。

### <span class="anchor-text-supplement">Can I send alerts?</span>アラートを送信できますか？

[Alertmanager](https://github.com/prometheus/alertmanager)でできる。

現在、以下の外部システムがサポートされている。

* Email
* Generic Webhooks
* [HipChat](https://www.hipchat.com/)
* [OpsGenie](https://www.opsgenie.com/)
* [PagerDuty](http://www.pagerduty.com/)
* [Pushover](https://pushover.net/)
* [Slack](https://slack.com/)

### <span class="anchor-text-supplement">Can I create dashboards?</span>ダッシュボードを作成できますか？

できる。プロダクションでの利用には[Grafana](/ja/docs/visualization/grafana/)を推奨している。
[コンソールテンプレート](/ja/docs/visualization/consoles/)もある。

### <span class="anchor-text-supplement">Can I change the timezone? Why is everything in </span>タイムゾーンを変更できるか？なぜ全てUTCなのか？

タイムゾーンに関するあらゆる混乱（特に、いわゆるdaylight saving timeに関わる混乱）を避けるために、Prometheusの全てのコンポーネントで、内部的にはUnix timeのみを、表示にはUTCのみを用いると決められている。UIには、慎重に選ばれたタイムゾーンを導入することができるかもしれない。この試みに関する現状は[issue #500](https://github.com/prometheus/prometheus/issues/500)を参照のこと。

## <span class="anchor-text-supplement">Instrumentation</span>メトリクス組み込み

### <span class="anchor-text-supplement">Which languages have instrumentation libraries?</span>どの言語にメトリクスを組み込むためのライブラリがありますか？

自分のサービスにPrometheusのメトリクスを組み込むためのライブラリはたくさんある。
詳細は[クライアントライブラリ](/ja/docs/instrumenting/clientlibs/)のドキュメントを参照すること。

新しい言語のためのクライアントライブラリに貢献する気がある場合、[出力フォーマット](/ja/docs/instrumenting/exposition_formats/)を参照すること。

### <span class="anchor-text-supplement">Can I monitor machines?</span>マシンを監視することはできますか？

できる。[Node Exporter](https://github.com/prometheus/node_exporter)は、Linuxや他のUnixシステムのCPU使用率、メモリ、ディスク利用率、ファイルシステム、ネットワーク帯域のような広範にわたるマシンレベルのメトリクスを出力する。

### <span class="anchor-text-supplement">Can I monitor network devices?</span>ネットワークデバイスを監視することはできますか？

できる。[SNMP Exporter](https://github.com/prometheus/snmp_exporter)によってSNMPをサポートしているデバイスを監視することができる。

### <span class="anchor-text-supplement">Can I monitor batch jobs?</span>バッチジョブを関することはできますか？

[Pushgateway](/ja/docs/instrumenting/pushing/)を使うことでできる。
バッチジョブの監視について[ベストプラクティス](/ja/docs/instrumenting/pushing/)も参照すること。

### <span class="anchor-text-supplement">What applications can </span>どんなアプリケーションがPrometheus<span class="anchor-text-supplement"> monitor out of the box?</span>ですぐに監視できますか？

[exporterとインテグレーションの一覧](/ja/docs/instrumenting/exporters/)を参照すること。

### <span class="anchor-text-supplement">Can I monitor </span>JVMアプリケーション<span class="anchor-text-supplement"> applications via </span>をJMXで監視できますか？

Javaクライアントで直接メトリクスを組み込めないアプリケーションに対しては、スタンドアロンでもJava Agentとしてでも[JMX Exporter](https://github.com/prometheus/jmx_exporter)を利用することができる。

### <span class="anchor-text-supplement">What is the performance impact of instrumentation?</span>メトリクスを組み込んだ場合のパフォーマンスへの影響は？

パフォーマンスは、クライアントライブラリや言語によって様々であろう。
Javaに関しては、[ベンチマーク](https://github.com/prometheus/client_java/blob/master/benchmark/README.md)によると、Javaクライアントのカウンター/ゲージを一つインクリメントするのに12〜17nsかかることが示唆されている。
これは、レイテンシーが致命的なほとんどのコード以外全てで無視できる。

## <span class="anchor-text-supplement">Troubleshooting</span>問題解決

### <span class="anchor-text-supplement">My </span>Prometheus 1.x<span class="anchor-text-supplement"> server takes a long time to start up and spams the log with copious information about crash recovery.</span>のサーバーが起動するのに長い時間がかかり、クラッシュ復旧に関するおびただしいログを出力します

Prometheusは`SIGTERM`の後で綺麗にシャットダウンしなければならず、激しく使われているサーバーではそれにしばらく時間がかかることもある。サーバーがクラッシュしたり、強制的に終了させられたり（例えば、メモリ不足でカーネルにkillされたり、Prometheusのシャットダウンの途中でランレベルシステムが待ちきれなくなったり）すると、クラッシュからの復旧が実行される。
これは普通の状況下では1分もかからないが、ある種の状況下ではかなり長い時間がかかることもあり得る。
詳細は、[crash recovery](/docs/prometheus/1.8/storage/#crash-recovery)を参照すること。

### <span class="anchor-text-supplement">My </span>Prometheus 1.x<span class="anchor-text-supplement"> server runs out of memory.</span>のサーバーがメモリ不足になります

Prometheusが利用可能なメモリ量を設定するために、[メモリ利用についてのセクション](/docs/prometheus/1.8/storage/#memory-usage)を参照すること。

### <span class="original-header">My </span>Prometheus 1.x<span class="anchor-text-supplement"> server reports to be in </span>のサーバーが“rushed mode”<span class="original-header"> or that </span>であるあるいは“storage needs throttling”だとレポートします

ストレージの負荷が高くなっている。
パフォーマンスをよくするためにどう設定を調整するか理解するために[ローカルストレージの設定についてのセクション](/docs/prometheus/1.8/storage/)を読むこと。

## <span class="anchor-text-supplement">Implementation</span>実装

### <span class="anchor-text-supplement">Why are all sample values </span>全ての値が64-bit float<span class="anchor-text-supplement">s? I want </span>なのはなぜですか？integer<span class="anchor-text-supplement">s.</span>がいいんですが…

設計を単純にするために64-bitのfloatに制限している。
[IEEE 754 倍精度浮動小数点数](https://ja.wikipedia.org/wiki/倍精度浮動小数点数)は、2^53までの精度の整数をサポートしている。
ネイティブの64bit integerをサポートしても、2^53〜2^63の精度の整数が必要な場合に役に立つだけである。
原理的には、他の型（64 bitよりも大きな整数の方を含む）のサポートは、実装可能ではあるが、現時点の優先事項ではない。
カウンターは、秒間100万回インクリメントされても、285年以上経たないと精度の問題にぶつからない。

### <span class="anchor-text-supplement">Why don't the </span>なぜPrometheus<span class="anchor-text-supplement"> server components support </span>サーバーはTLS<span class="anchor-text-supplement"> or authentication? Can I add those?</span>や認証をサポートしないのですか？追加できますか？

注意：Prometheusチームは、2018年8月11日のdevelopment summitでこれに関する姿勢を変更した。
提供しているエンドポイントのTLSと認証のサポートは[プロジェクトのロードマップ](/ja/docs/introduction/roadmap/#tls-and-authentication-in-http-serving-endpoints)に記載されている。
コードが変更されたら、このドキュメントは更新されるだろう。

TLSと認証はよくリクエストされる機能ではあるが、意図的に、Prometheusのサーバーサイドのコンポーネントに実装してこなかった。
どちらも非常にたくさんの選択肢とパラメーターがある（TLSだけでも10以上ある）ので、サーバーコンポーネントで完全に一般的なTLSと認証をサポートするのではなく、可能な限り最善の監視システムを構築することに集中しようと決めていた。

TLSや認証が必要な場合、Prometheusの前にリバースプロキシを置くことを推奨する。
例えば、[Adding Basic Auth to Prometheus with
Nginx](https://www.robustperception.io/adding-basic-auth-to-prometheus-with-nginx/)を参照すること。

これはPrometheusへの接続に限った話である。
Prometheusは、[TLSや認証がかかったターゲットのスクレイプ](/ja/docs/operating/configuration/#%3Cscrape_config%3E)をサポートしている。他のPrometheusコンポーネントにも同様のサポートがある。