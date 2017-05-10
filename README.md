# 対話型 ES 作成アプリ

フロント側は Apple のフレームワークのみ使用. 
バックエンドは Python. Siri の音声認識エンジンを使い、AI と会話をすることで ES を完成させていく. 

## セットアップ

```
git clone https://github.com/naru-hiyoko/EKES_APP.git
cd EKES_APP/EKMensetsu
```
[ここから](https://drive.google.com/open?id=0B4DS3kS5-yHfR0xWdzFhRnhMWkE)
リソースをダウンロードし, 上のディレクトリにコピーする. <br>
### デバッグモード でのビルド
XCode 上から ビルドの前に AI.swift の AI, AICloud の URL 部分を環境に合わせて修正する. <br>
また、ビルドの際には Product -> Scheme -> Edit Scheme -> Build Configuration を Debug にしておく. 

```
class AI : NSObject
{
    
    #if DEBUG
    static let register_url: URL = URL.init(string: "http://192.168.1.4/register.py")!
    #else
    static let register_url: URL = URL.init(string: "http://.ddns.net:21000/register.py")!
    #endif
    
}

class AICloud
{
    #if DEBUG
//    let url = URL.init(string: "http://192.168.1.3:8000/cgi-bin/server.py")
    let url = URL.init(string: "http://192.168.1.4:21000/server.py")
    #else
    let url = URL.init(string: "http://.ddns.net:21000/server.py")
    #endif
    private var session : URLSession!
   

```

### ローカルサーバーの準備
バックエンドは、シナリオの進行を制御するサービスとデータベース関連のサービスをそれぞれサーバで立ち上げる。<br>
ローカル環境でのテストは CGI 用のテストコード が python/ に入っている. debug.html は 前者の CGI テスト用. 
<br>
python/ 以下で

```
python3 -m http.server --cgi

```
アプリケーションからは server.py ないし server-interactive.py にアクセスする. <br>
本番用のサーバー側プログラムは未公開. <br>
Note: mirror.py の形で受け取ったら、その後の処理お願いします。

