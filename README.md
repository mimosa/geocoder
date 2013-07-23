部署说明
====

`cd geocoder`
* 加执行权限

`chmod +x ./bin/migrate.sh`
* 请确保 `redis-server` 运行
* 导入 手机号段 及 身份证号段 数据

`./bin/migrate.sh`
* 运行 `Jetty` 下

`mizuno`
* 打成 `war` 包

`bundle exec warble`


GEO 调用说明
====

[IP地址](http://open.shou65.com/api/geocoder/113.140.219.74)

[手机号](http://open.shou65.com/api/geocoder/18016245161)

[凯翔小区](http://open.shou65.com/api/geocoder/凯翔小区)

[身份证](http://open.shou65.com/api/geocoder/610103198006220000)

短网址 调用说明
====

[新浪](http://open.shou65.com/api/shortener/sina?long_url=http%3a%2f%2fwww.google.com%2flogin.jsp?user_id=1)

[腾讯](http://open.shou65.com/api/shortener/tencent?long_url=http%3a%2f%2fwww.google.com%2flogin.jsp?user_id=1)

[短信](http://smsbao.com)发送 调用说明
====

### 兑换 API_KEY


```bash
curl \
  -H 'Content-Type: application/json' \
  -i 'http://open.shou65.com/api/smssender/token?login=用户名&amp;passwd=密码'		
```
* 返回

```json
{
	"X-Auth-Token": "密钥"
}
```

### 发送短信
* 带返回的 POST
* 群发，用 *逗号* 隔开，多个手机号

```bash
curl \
	-X POST \
	-H 'X-Auth-Token: 密钥' \
	-H 'Content-Type: application/json' \
	-d '{ "mobile": "手机号", "content": "短信测试" }' \
	-i 'http://open.shou65.com/api/smssender'
```
* 单发，返回

```json
{
  "success": true,
  "message": "短信发送成功",
  "fee": "当前发送，消耗的短信条数"
}
```

* 群发，返回

```json
{
  "success":true,
  "message":"短信队列成功。",
  "pending": ["数组，未发送的手机号"],
  "sent": ["数组，发送成功的手机号"],
  "fail": ["数组，发送失败的手机号"],
  "fee": "当前发送，消耗的短信条数"
}
```



### 查询余额

```bash
curl \
	-H 'X-Auth-Token: 密钥' \
	-H 'Content-Type: application/json' \
	-i 'http://open.shou65.com/api/smssender'
```
* 返回

```json
{
    "success": true,
    "message": {
        "sent": "已发送条数",
        "balance": "剩余条数"
    }
}
```
简单的配置文件 调用说明
====

### 创建设置文件
* '/api/settings/{配置名称}'；
* 跳转至查看；

```bash
curl \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '[{"area_code":"021", "pinyin": "shanghai", "country": "中国", "city": "上海"},{"area_code":"0755", "pinyin": "shenzhen", "country": "中国", "city": "深圳"}]' \
  -i 'http://open.shou65.com/api/settings/cities'
```

### 查看设置
* '/api/settings/{密钥}'；

```bash
curl \
  -H 'Content-Type: application/json' \
  -i 'http://open.shou65.com/api/settings/S2hmUWticlcxd1U9'
```
* 返回

```json
[
  {
    area_code: "021",
    pinyin: "shanghai",
    country: "中国",
    city: "上海"
  },
  {
    area_code: "0755",
    pinyin: "shenzhen",
    country: "中国",
    city: "深圳"
  }
]
```

### 查询设置
* '/api/settings/{密钥}/search/{字段}?q={关键字}'；

```bash
curl \
  -H 'Content-Type: application/json' \
  -i 'http://open.shou65.com/api/settings/S2hmUWticlcxd1U9/search/pinyin?q=sh'
```
* 返回

```json
[
  {
    area_code: "021",
    pinyin: "shanghai",
    country: "中国",
    city: "上海"
  },
  {
    area_code: "0755",
    pinyin: "shenzhen",
    country: "中国",
    city: "深圳"
  }
]
```
