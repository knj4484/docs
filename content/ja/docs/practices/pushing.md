---
title: いつPushgatewayを使うべきか
sort_rank: 7
---

# <span class="original-header">When to use the </span>いつPushgatewayを使うべきか

Pushgatewayは、スクレイプすることができないジョブからメトリクスをプッシュできるようにするための中間的なサービスである。
詳細は、[メトリクスのプッシュ](/ja/docs/instrumenting/pushing/)を参照。

## <span class="original-header">Should I be using the </span>Pushgatewayを使うべきか？

**特定の限られた場合にのみPushgatewayを利用することを推奨する。**
一般的なメトリクスの収集に、Prometheusの通常のpullモデルの代わりにPushgatewayを盲目的に使うと落とし穴にはまることがある。

* 複数のインスタンスを一つのPushgatewayを通して監視すると、Pushgatewayが単一障害点になり、ボトルネックとなる可能性もある
* scrapeする毎に生成される`up`メトリックによるインスタンスのヘルスチェックができなくなる
* Pushgatewayは、（Pushgateway APIを使って手動で削除しない限り）送られてきたデータを失うことがなくデータを出力し続ける

最後の点は、あるジョブの複数のインスタンスが、`instance`ラベル（または類似のもの）を使ってPushgatewayにあるメトリクスを区別する場合には重要である。
あるインスタンスのメトリクスは、インスタンスが名前変更や削除されても保持されたままになる。したがって、メトリクスのキャッシュとしてのPushgatewayのライフサイクルは、メトリクスをpushしてくるプロセスのライフサイクルと本質的に分離されているからである。
Prometheusの通常のpullスタイルの監視と比較してみると、インスタンスが消えたときに（意図的であるかどうかに関わらず）、そのメトリクスも同時に自動的に消える。
Pushgatewayを使うと、こうはならないので、古くなったメトリクスは手動で消すか、ライフサイクル同期を自分で自動化しなければならないだろう。

**Pushgatewayの唯一の正当な利用方法は、サービスレベルのバッチの出力を追跡することである。**「サービスレベル」のバッチとは、特定のマシンやジョブインスタンスに意味的に結びついていないもののこと（例えば、サービス全体の多くのユーザーを削除するバッチ）である。そのようなジョブのメトリクスは、メトリクスから特定のマシンやインスタンスのライフサイクルを分離するために、マシンやインスタンスのラベルを含むべきではない。こうすることで、Pushgatewayにある古くなったメトリクスを管理する負荷を減らすことが出来る。
[バッチジョブ監視のベストプラクティス](/ja/docs/practices/instrumentation/#batch-jobs)も参照すること。

## <span class="original-header">Alternative strategies</span>代替手段

もしファイアウォールやNATが監視対象からのpullを妨げているなら、Prometheusサーバーのファイアウォール内への移動を考えること。
Prometheusのサーバーを監視対象と同じネットワークで稼働させることが一般的に推奨されている。

マシンに紐づいたバッチジョブ（自動セキュリティ更新のためのcronジョブや設定管理クライアントの実行）のためには、Node Exporterの
[Textfile Collector](https://github.com/prometheus/node_exporter#textfile-collector)を用いて、結果のメトリクスを出力すること。
