---
title: クライアントライブラリの書き方
sort_rank: 2
---

# <span class="original-header">Writing client libraries</span>クライアントライブラリの書き方

このドキュメントは、簡単なユースケースは簡単にし、ユーザーを間違った方向へ導いてしまう機能を回避できるようなライブラリ間の一貫性を目的として、Prometheusクライアントライブラリがどのような機能とAPIを提供すべきかについて説明する。

これを書いている時点で、[10言語](/ja/docs/instrumenting/clientlibs)でサポートされており、クライアントをどう書くかについてよく分かっている。
このガイドラインは、新しいクライアントライブラリの作者が良いライブラリを開発する助けになることを目的としている。

## <span class="original-header">Conventions</span>慣例

「しなければならない（ MUST ）」、 「してはならない（ MUST NOT ）」、 「する必要がある（ SHOULD ）」、「しないほうがよい（ SHOULD NOT ）」、「してもよい（ MAY ）」は、[https://www.ietf.org/rfc/rfc2119.txt](https://www.ietf.org/rfc/rfc2119.txt)（[日本語訳](https://www.ipa.go.jp/security/rfc/RFC2119JA.html)）で定められた意味を持つ。

さらに、「するのが望ましい（ENCOURAGED）」は、ライブラリがある機能を持っているのが望ましいがなくてもよいという意味である。
言い換えると、あると良い機能である。

心に留めておくべきことは以下の通り。

* それぞれの言語の機能を活かすこと
* よくあるユースケースは簡単である必要がある
* 何かを正しくするやり方が一番簡単なやり方である必要がある
* より複雑なユースケースが可能である必要がある

よくあるユースケースを順に示す。

* ライブラリ/アプリケーション中に大量に散らばったラベルのないカウンター
* サマリー/ヒストグラムでの関数/ブロックのコードの時間計測
* ものごとの現在の状態（およびその限度）を追跡するするためのゲージ
* バッチジョブの監視

## <span class="original-header">Overall structure</span>全体の構造

クライアントは、内部的にはコールバックベースで書かれていなければならない（MUST）。
クライアントは、一般的にここで述べられている構造に従っている必要がある（ SHOULD ）。

鍵となるクラスはCollectorである。
このクラスは、0個以上のメトリクスとその値を返す（典型的にはcollectという）メソッドを持っている。
Collectorは、CollectorRegistryに登録される。
データは、CollectorRegistryをクラス/メソッド/関数bridgeに渡すことで出力される。
bridgeは、Prometheusがサポートしているフォーマットでメトリクスを返す。
CollectorRegistryは、スクレイプされるたびに、各Collectorのcollectメソッドをコールバックしなければならない。

ほとんどのユーザーが利用するインターフェースは、Counter、Gauge、Summary、HistogramのCollectorである。
これらは1つのメトリックを表し、ユーザーが自分のコードにメトリクスを組み込むユースケースの大部分を含んでいるはずである。

他の監視システムからのプロキシのような、より高度なユースケースでは、独自Collectorを書くことが要求される。
ユーザーが1つのメトリクス組み込みの仕組みを考えるだけで済むように、CollectorRegistryから別の監視システムが理解できるフォーマットのデータを生成するbridgeを書きたい人もいるだろう。

CollectorRegistryは、関数`register()`/`unregister()`を提供する必要があり（SHOULD）、Collectorは、複数のCollectorRegistryに登録されてもよくなっている必要がある（SHOULD）。

クライアントライブラリは、スレッドセーフでなければならない（MUST）。

Cのように、オブジェクト指向でない言語では、現実的な範囲でこの構成になるよう心がけるべきである。

### <span class="original-header">Naming</span>命名

クライアントライブラリは、取り組んでいる言語の命名規約を鑑みつつ、このドキュメントに書かれている関数/メソッド/クラス/名に従う必要がある（SHOULD）。
例えば、Pythonでは`set_to_current_time()`が酔いが、Goでは`SetToCurrentTime()`の方がよく、Javaでは`setToCurrentTime()`が慣例である。
関数のオーバーロードが許されないなどの技術的な理由で名前が異なる場合は、ドキュメントやヘルプ文字列で、ユーザーに他の名前も示す必要がある（SHOULD）。

ライブラリは、ここであげるものと同じまたは類似の名前で別の意味を持つ関数/メソッド/クラスを提供してはならない（MUST NOT）。

## <span class="original-header">Metrics</span>メトリクス

カウンター、ゲージ、サマリー、ヒストグラムの[メトリック型](/ja/docs/concepts/metric_types/)が、ユーザーが使う主要なインターフェースである。

カウンターとゲージは、クライアントライブラリに含まれていなければならない（MUST）。
少なくともサマリーかヒストグラムのどちらかが提供されていなければならない（MUST）。

これらは、主に、ファイルスコープの静的な変数、つまりそれらが利用されるファイルと同じファイルで定義されるグローバル変数のはずである。
クライアントライブラリは、これをできるようにする必要がある（SHOULD）。
よくあるユースケ〜スは、あるオブジェクトの1つのインスタンスのコンテキストにあるコード断片ではなく、いろいろなところにあるコード断片にメトリクスを実装することである。
ユーザーがメトリクスを辿って自分のコードをくまなく調べる必要があってはいけない。
クライアントライブラリがユーザーのためにそれをするべきである。
そうでなければ、それを容易にするためのライブラリのラッパーをユーザーが書くことになるだろうが、それはうまくいくことは稀である。

デフォルトのCollectorRegistryがなければならない（MUST）。
標準のメトリックは、デフォルトで、ユーザーに必要な特別な作業なしに、暗黙的にそのCollectorRegistryに登録しなければならない（MUST）。
メトリクスがデフォルトのCollectorRegistryに登録されないようにする方法がなければならない（MUST）。
独自のcollectorもこれに従う必要がある（SHOULD）。

メトリクスを作成する詳細な方法は言語によって異なるはずである。
例えば、いくつかの言語（例えばJavaやGo）ではビルダーが最善の方法である一方で、他の言語（例えばPython）では関数の引数が、1回の呼び出しで同じことをできるだけの十分な表現力がある。

例えば、Java Simpleclientでは以下のようになる。

```java
class YourClass {
  static final Counter requests = Counter.build()
      .name("requests_total")
      .help("Requests.").register();
}
```

これはリクエストをデフォルトのCollectorRegistryに登録する。
`register()`ではなく`build()`を呼び出したことで、このメトリックは登録されるない（単体テストに便利である）。
`register()`にCollectorRegistryを渡すこともできる（バッチジョブに便利である）。

### <span class="original-header">Counter</span>カウンター

[カウンター](/ja/docs/concepts/metric_types/#counter)は、単調増加するカウンターである。
カウンターは、値を減少させてはならない（MUST NOT）が、サーバーの再起動などで、0にリセットしてもよい（MAY）。

カウンターは以下のメソッドを持たなければならない（MUST）。

* `inc()`: 1でカウンターをインクリメントする
* `inc(double v)`: 与えられた量でカウンターをインクリメントする。v >= 0であることをチェックしなければならない（MUST）。

カウンターは以下の機能を持つのが望ましい（ENCOURAGED）。

あるコード断片での例外のthrow/raisedを数える方法と、オプションで特定の例外の型にだけそうする方法。
これはPythonでは、count_exceptionsである。

カウンターは0で始まらなければならない（MUST)。

### <span class="original-header">Gauge</span>ゲージ

[ゲージ](/ja/docs/concepts/metric_types/#gauge)は、増加/減少する値を表す。

ゲージは以下のメソッドを持たなければならない（MUST）。

* `inc()`: ゲージを1でインクリメントする
* `inc(double v)`: 与えられた量でゲージをインクリメントする
* `dec()`: ゲージを1でデクリメントする
* `dec(double v)`: 与えられた量でゲージをデクリメントする
* `set(double v)`: ゲージを与えられた値にセットする

ゲージは0で始まらなければならない（MUST)。
ゲージが別の数で始まる方法を提供してもよい（MAY）。

ゲージは以下のメソッドを持つ必要がある（SHOULD）。

* `set_to_current_time()`: ゲージを現在のUNIX時間（秒）にセットする

ゲージは以下の機能を持つのが望ましい（ENCOURAGED）。

コード/関数の断片で進行中のリクエストを追跡する方法。
これはPythonでは、`track_inprogress`である。

コード断片の時間を計り、ゲージをその時間（秒）にセットする。
これはバッチジョブに便利である。
これはJavaでは、startTimer/setDurationであり、Pythonでは、`time()` decorator/context managerである。
これは、サマリー/ヒストグラムのパターンに合わせる（ただし`observe()`の代わりに`set()`とする）必要がある（SHOULD）。

### <span class="original-header">Summary</span>サマリー

[サマリー](/ja/docs/concepts/metric_types/#summary)は、時間のスライディングウインドウに渡る（普通はリクエスト時間のような）観測値を採取し、ある特定の瞬間のその分布、頻度、合計に関する情報を提供する。

サマリーは、内部的にサマリーの分位数に割り当てられるので、"quantile"をユーザーにラベル名としてセットさせてはならない（MUST NOT）。
サマリーは、（集約ができず、遅いが）分位数を出力するのが望ましい（ENCOURAGED）。
サマリーは、`_count`/`_sum`だけで十分便利なので、分位数を持たなくてもよいようにしなければならない（MUST）。
また、これがデフォルトでなければならない（MUST）。

サマリーは以下のメソッドを持たなければならない（MUST）。

* `observe(double v)`: 与えられた量を観測する

サマリーは以下のメソッドを持つ必要がある（SHOULD）。

コードの時間を秒で計る何らかの方法。
Pythonでは、これは`time()`decorator/context managerである。
Javaでは、これは`startTimer`/`observeDuration`である。
秒以外の単位を提供してはならない（MUST NOT）。ユーザーは他の単位が欲しければ自分ですることができる。
これは、ゲージ/ヒストグラムと同じパターンに従っているべきである。

サマリーの`_count`/`_sum`は0から始まらなければならない（MUST）。

### <span class="original-header">Histogram</span>ヒストグラム

[ヒストグラム](/ja/docs/concepts/metric_types/#histogram)は、リクエストのレイテンシーのようなイベントの分布が集約可能になる。
ヒストグラムは、本質的には、バケットごとのカウンターである。

ヒストグラムは、内部的にバケットに`le`が割り当てられるので、`le`をユーザーにセットされるラベルとして許可してはならない（MUST NOT）。

ヒストグラムは、手動でバケットを選択する方法を提供しなければならない。
`linear(start, width, count)`と`exponential(start, factor,count)`のような方法でバケットをセットする方法を提供する必要がある（SHOULD）。
カウントは`+Inf`のバケットを含んでいなければならない（MUST）。

ヒストグラムは、他のクライアントライブラリと同じデフォルトのバケットを持つ必要がある（SHOULD）。
バケットは、一旦作成されたら、変更可能であってはならない（MUST NOT）。

ヒストグラムは以下のメソッドを持たなければならない（MUST）。

* `observe(double v)`: 与えられた量を観測する

ヒストグラムは以下のメソッドを持つ必要がある（SHOULD）。

コードの時間を秒で計る何らかの方法。
Pythonでは、これは`time()`decorator/context managerである。
秒以外の単位を提供してはならない（MUST NOT）。ユーザーは他の単位が欲しければ自分ですることができる。
これは、ゲージ/サマリーと同じパターンに従っているべきである。

ヒストグラムの`_count`/`_sum`およびバケットは0から始まらなければならない（MUST）。

**さらなるメトリクスの検討**

ここまでに書かれていること以上の追加の機能を提供することは、それが特定の言語で意味をなすようなものならば、望ましい（ENCOURAGED）。

よりシンプルにできるよくあるユースケースがあれば、望まない振る舞い（最適ではないメトリック/ラベルの構成、クライアントでの計算）が助長されない限り、そうすること。

### <span class="original-header">Labels</span>ラベル

ラベルは、Prometheusの[最も強力な機能](/ja/docs/practices/instrumentation/#use-labels)の1つであるが、[簡単に使い過ぎになる](/ja/docs/practices/instrumentation/#do-not-overuse-labels)。
従って、クライアントライブラリは、ラベルがどのようにユーザーに提供されるかについてかなり気をつけなければならない。

クライアントライブラリは、いかなる状況でも、ゲージ/カウンター/サマリー/ヒストグラムや他のいかなるCollectorに対しても、ユーザーに同じメトリックに異なるラベルを持たせることがあってはならない（MUST NOT）。

独自のcollectorからのメトリックは、ほぼ常に、一貫したラベル名になっているべきである。
かなり稀だがこれが当てはまらない正当なユースケースもあるので、クライアントライブラリはラベル名の検証をすべきではない。

ラベルが強力である一方で、メトリクスの大多数はラベルを持たないだろう。
したがって、APIはラベルを許すべきだが、強制すべきではない。

クライアントライブラリは、ゲージ/カウンター/サマリー/ヒストグラム作成時点でラベル名のリストをオプションで指定できるようにしなければならない（MUST）。
クライアントライブラリは、任意の数のラベル名をサポートする必要がある（SHOULD）。
クライアントライブラリは、ラベル名が[ドキュメントに書かれている要件](/ja/docs/concepts/data_model/#metric-names-and-labels)に合っているか検証しなければならない（MUST）。

あるメトリックのラベル付けされた要素にアクセスする一般的な方法は、ラベル値のリストまたはラベル名からラベル値へのマップのどちらかをとり、"Child"を返す`labels()`メソッドである。
その後、`.inc()`/`.dec()`/`.observe()`などのメソッドは、そのChildに対して呼び出すことができる。

`labels()`が返したChildは、再び検索する必要性を避けるために、ユーザーによるキャッシュが可能になっている必要がある（SHOULD）。
これは、レイテンシーが致命的なコードで問題になる。

Metrics with labels SHOULD support a `remove()` method with the same signature
as `labels()` that will remove a Child from the metric no longer exporting it,
and a `clear()` method that removes all Children from the metric. These
invalidate caching of Children.
ラベル付きのメトリクスは、`labels()`と同じシグネチャーを持つ`remove()`メソッドをサポートする必要がある（SHOULD）。
メトリックからXXXChildを削除する
`clear()`メソッドは、メトリックから全てのchildrenを削除する。
これらのメソッドはChildrenのキャッシュを無効にする。

与えられたChildをデフォルト値で初期化する方法（普通は`labels()`を呼び出すだけ）がある必要がある（SHOULD）。
[メトリクスの欠落の問題](/ja/docs/practices/instrumentation/#avoid-missing-metrics)を回避するために、ラベルのないメトリクスは常に初期化されなければならない。

### <span class="original-header">Metric names</span>メトリック名

メトリック名は、[仕様](/ja/docs/concepts/data_model/#metric-names-and-labels)に従わなければならない。
ラベル名と同様に、ゲージ/カウンター/サマリー/ヒストグラムの使い方およびそのライブラリで提供されている他のCollectorに合っていなければならない（MUST）。

多くのクライアントライブラリが3つの部分からなる名前`namespace_subsystem_name`を設定する方法を提供している。
この中で`name`だけが必須である。

独自のCollectorが他の監視システムからプロキシする場合を除いて、メトリック名またはメトリック名の一部を動的にするまたは生成することは、抑止されなければならない（MUST）。
メトリック名を動的にするまたは生成することは、代わりにラベルを使うべきであるという兆しである。

### <span class="original-header">Metric description and help</span>メトリックの説明とヘルプ

ゲージ/カウンター/サマリー/ヒストグラムは、メトリックの説明とヘルプが提供されることを要求しなければならない（MUST）。

クライアントライブラリに付属する独自のCollectorには、そのメトリクスに関する説明とヘルプがなければならない（MUST）。

必須の引数にするが特定の長さになっていることをチェックはしないことが提案されている。
なぜなら、誰かがdocsを書きたくないなら我々はその人にdocsが書きたくなるように説得することはないからである。
ライブラリで提供されているCollector（および、実際にはエコシステムのできる限り全ての所で）は、良質のメトリックの説明を提供する必要がある（SHOULD）。

## <span class="original-header">Exposition</span>出力

クライアントは、[出力フォーマット](/ja/docs/instrumenting/exposition_formats)のドキュメントに書かれているテキストベースの出力フォーマットを実装しなければならない（MUST）。

多大なコストを必要とせず実装できるなら、（特に人間にとって可読性の高いフォーマットにするために）出力されるメトリクスを再現性のある順番にすることが望ましい（ENCOURAGED）。

## <span class="original-header">Standard and runtime </span>標準的なランタイムのcollector<span class="original-header">s</span>

クライアントライブラリは、後述の標準的なライブラリが出力しているもののうち可能なものは提供する必要がある（SHOULD）。

これらは、独自のcollectorとして実装され、デフォルトでデフォルトのCollectorRegistryに登録される必要がある（SHOULD）。
これらが邪魔になるとてもニッチなユースケースがあるので、これらを無効にする方法がある必要がある（SHOULD）。

### <span class="original-header">Process metrics</span>プロセスのメトリクス

これらの出力は`process_`というプリフィックスをつける必要がある。
言語やランタイムからこれらの数値のどれかを取得できないならば、クライアントライブラリがそれを出力することはないだろう。
全てのメモリ関連の値の単位はバイト、全ての時間関連の値はunixtime/秒である。

| メトリック名                         | ヘルプ文字列                          | 単位         |
| ---------------------------------- | ----------------------------------- | ----------  |
| `process_cpu_seconds_total`        | ユーザーおよびシステムの消費CPU時間（秒） | 秒           |
| `process_open_fds`                 | オープンしているファイル記述子の数       | ファイル記述子 |
| `process_max_fds`                  | オープンできるファイル記述子の上限       | ファイル記述子 |
| `process_virtual_memory_bytes`     | 仮想メモリのサイズ（バイト）            | バイト        |
| `process_virtual_memory_max_bytes` | 利用可能な仮想メモリの上限（バイト）     | バイト        |
| `process_resident_memory_bytes`    | 常駐メモリのサイズ（バイト）            | バイト        |
| `process_heap_bytes`               | プロセスのヒープサイズ（バイト）         | バイト        |
| `process_start_time_seconds`       | プロセスの開始時間（unixエポックからの秒）| 秒           |

### <span class="original-header">Runtime metrics</span>ランタイムのメトリクス

さらに、クライアントライブラリは、言語のランタイムのメトリクスという観点で意味のあるもの（例えば、GCの統計）ならなんでも、適切なプリフィックス（例えば`go_`、`hostspot_`など）を付けて提供することが望ましい（ENCOURAGED）。

## <span class="original-header">Unit tests</span>単体テスト

クライアントライブラリには、メトリクス組み込みの中核および出力をカバーする単体テストがある必要がある（SHOULD）。

クライアントライブラリは、ユーザーが自分のメトリクス組み込みコードを単体テストするのが簡単になる方法を提供することが望ましい（ENCOURAGED）。
例えば、Pythonでは、`CollectorRegistry.get_sample_value`がある。

## <span class="original-header">Packaging and dependencies</span>パッケージと依存

理想を言えば、クライアントライブラリは、どんなアプリケーションにも、アプリケーションを壊すことなく、メトリクスを追加するためにインクルードできる。

したがって、クライアントライブラリへの依存を追加する際には注意すること。
例えば、あるライブラリのバージョンx.yを必要とするPrometheusクライアントを使うライブラリを追加したが、そのアプリケーションがどこかでバージョンx.zを使っているとすると、アプリケーションにとって好ましくない影響があるだろうか？

こういった問題が出てきたら、中核となるメトリクス組み込みを、特定のフォーマットでのメトリクスのブリッジ/出力から分離することが推奨されている。
例えば、Javaのモジュール`simpleclient`は依存がなく、`simpleclient_servlet`がHTTPの依存を少し持っている。

## <span class="original-header">Performance considerations</span>パフォーマンスの考慮

クライアントライブラリはスレッドセーフでなければならないので、なんらかの形で並行性の制御が必要であり、マルチコアのマシンとアプリケーション上でのパフォーマンスを考慮しなければならない。

我々の経験では、mutexのパフォーマンスが一番低い。

プロセッサのアトミックな操作が中間的であり、一般的に許容される。

Javaのsimpleclientで使われているDoubleAdderのような、異なるCPUがRAMの同じビットを変更するのを防ぐ方法が一番うまく行く。
ただし、メモリのコストがある。

上で述べたように、`labels()`の結果はキャッシュ可能である必要がある。
ラベル付きのメトリックに使われることが多いconcurrent mapは、かなり遅くなりがちである。
ラベルのないメトリクスが`labels()`のような検索を避けるように特別に場合分けするのはかなり役立つ。

スクレイプの最中にアプリケーション全体が止まってしまうのは望ましくないので、メトリクスがincremented/decremented/setなどをされている間にブロックするのを避ける必要がある（SHOULD）。

ラベルを含む主なメトリクス組み込み操作のベンチマークがあることが望ましい（ENCOURAGED）。

出力をする際には、リソース消費（特にRAM）に気をつける必要がある。
結果を少しずつ出力したり、同時にスクレイプする数に制限を設けることで、メモリフットプリントの削減を検討すること。
