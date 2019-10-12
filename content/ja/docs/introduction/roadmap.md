---
title: ロードマップ
sort_rank: 6
---

# <span class="anchor-text-supplement">Roadmap</span>ロードマップ

以下に記すのは、近い将来に実装する予定の主な機能からいくつかを選んだものである。
予定されている機能および現在の取り組みの完全な概要は、各種リポジトリのイシュートラッカー（例えば、[Prometheusサーバー](https://github.com/prometheus/prometheus/issues)）を参照すること。


### <span class="anchor-text-supplement">Server-side metric metadata support</span>サーバーサイドでのメトリックメタデータのサポート

現在、メトリックの型および他のメタデータは、クライアントライブラリと出力フォーマットで用いられているだけで、Prometheusサーバーで保持されたり利用されたりしていない。
将来は、このデータを利用する予定である。
まずは、このデータをPrometheusのメモリ内に集め、実験的なAPIエンドポイントを通して提供する。

### <span class="anchor-text-supplement">Adopt </span>OpenMetricsの採用

OpenMetricsワーキンググループは、メトリックの出力に関して新しい標準を作成中である。
このフォーマットをクライアントライブラリとPrometheus自体でサポートする予定である。

### 時系列の埋め直し（backfill）<span class="anchor-text-supplement"> time series</span>

backfillは、過去データをまとめて読み込めるようにする。
これで、過去に遡ってルールを評価したり、他のシステムから古いデータを転送することができるようになる。

### TLS<span class="anchor-text-supplement"> and authentication in </span>と認証のHTTP<span class="original-header"> serving endpoints</span>エンドポイントへの組み込み

Prometheus、Alertmanager、公式exporterのHTTPエンドポイントには、TLSと認証の組み込みでのサポートがまだない。
これをサポートすることで、外からこの機能を付け足すためのリバースプロキシが必要なくなり、ユーザーがPrometheusのコンポーネントをデプロイすることが簡単になる。

### <span class="anchor-text-supplement">Support the Ecosystem</span>エコシステムのサポート

Prometheusには、幅広いクライアントライブラリとexporterがあるが、
サポートし得る言語、メトリクスを出力すると便利なシステムがまだまだある。
これらの作成、発展においてエコシステムを支援する。
