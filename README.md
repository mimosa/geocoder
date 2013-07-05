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


API 调用说明
====

[IP地址](http://geo.shou65.com/?loc=113.140.219.74)

[手机号](http://geo.shou65.com/?loc=18016245161)

[凯翔小区](http://geo.shou65.com/?loc=凯翔小区)

[身份证](http://geo.shou65.com/?loc=610103198006220000)
