---
title: Alertmanager
sort_rank: 2
nav_icon: sliders
---

# Alertmanager

[Alertmanager](https://github.com/prometheus/alertmanager)は、Prometheusサーバーのようなクライアントアプリケーションから送信されたアラートを処理する。
重複を排除したり、グルーピングしたり、emailやPageDuty、OpsGenieのようなレシーバー連携にアラートを送信する。
また、アラートを一時停止したり、抑制したりする。

以下、Alertmanagerが実装しているコアとなる概念を説明する。
これらの詳細な使い方は、[設定ドキュメント](../configuration)を参照すること。

## <span class="original-header">Grouping</span>グループ化

グループ化は、似た性質のアラートを1つの通知に分類する。
これは、多くのシステムが一度に失敗し、何百、何千のアラートが同時に起こる大規模障害において特に有益である。

**例：**ネットワークの分断が起きた時に、何十、何百のサービスのインスタンスがクラスタで稼働していたとする。
サービスインスタンスの半分がデータベースにアクセスできない。
Prometheusのアラートルールは、データベースに通信できない時にサービスインスタンスそれぞれに対して1つのアラートを送信するように設定されている。結果として、Alertmanagerに何百ものアラートがAlertmanagerに送信される。

ユーザーとしては、どのサービスインスタンスが影響を受けたか正確に把握しつつ、1つの呼び出しを受けるだけにしたい。
そのために、Alertmanagerがアラートをクラスタとアラート名でまとめ、1つの簡潔な通知を送信するように設定できる。

アラートのグループ化、グループ化された通知のタイミング、それらの通知のレシーバーは、設定ファイルのルーティングツリーで設定される。

## 抑制（inhibition）

抑制（inhibition）とは、他のアラートがすでに起きている場合に特定のアラートの通知を抑制する概念である。

**例：**クラスタ全体がアクセス不能になっていることを知らせるアラートが起きているとする。
Alertmanagerは、そのアラートが起きている場合にこのクラスタに関する他の全てのアラートをミュートするように設定できる。
これによって、本当の問題と無関係なアラートが何百、何千と起きたと通知するのを避けることができる。

抑制は、Alertmanagerの設定ファイルを通して設定される。

## <span class="original-header">Silences</span>サイレンス

サイレンスは、指定された時間、単純にミュートする分かりやすい方法である。
サイレンスは、ルーティングツリーのように、マッチャーを元に設定される。
入ってきたアラートは、アクティブなサイレンスの全ての等値・正規表現マッチャーにマッチするか調べられる。
マッチした場合は、そのアラートに対して通知は送られない。

サイレンスは、AlertmanagerのWebインターフェースで設定される。

## <span class="original-header">Client behavior</span>クライアントの振る舞い

Alertmanagerは、クライアントの振る舞いに対して[特別な要件](../clients)を持っている。
それらの要件に関係があるのは、アラートを送信するのにPrometheusを使わない高度なユースケースだけである。

## <span class="original-header">High Availability</span>高可用性

Alertmanagerは、高可用なクラスタを構築するための設定をサポートしている。
これは、フラグ[--cluster-*](https://github.com/prometheus/alertmanager#high-availability)を利用して設定することができる。

PrometheusとAlertmanagerの間をロードバランスせず、代わりにPrometheusを全てのAlertmanagerのリストに向けさせることが重要である。
