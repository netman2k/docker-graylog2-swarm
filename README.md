
## 사용방법
### 설정
Graylog가 접속할 MongoDB와 ElasticSearch URL을 수정한다.
설정파일은 env/common에 다음과 같이 존재한다.

```
MONGODB_URI="mongodb://mongos1:27017,mongos2:27017/graylog"
ELASTICSEARCH_URL="http://elasticsearch:9200"
```

### 마스터 서버 기동
```
./master-up.sh
```

### 슬레이브 서버 기동
```
./slave-up.sh
```

### 슬레이브 서버 스케일링
```
docker service scale graylog2-slave=<수>
```
