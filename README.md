
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

## 스크립트 설명
- update_default_indexset.sh
기본으로 설정되어져있는 Default indexset 설정 변경 명령을 내리는 스크립트
- 예제
다음은 graylog.example.net으로 서비스 중인 Graylog2가 사용 중인 ElasticSearch의 shard와 replicas 설정을 변경하는 방법을 보여준다.
그 외 기타 설정은 내부 스크립트 상당에 변수로 설정되어있으니 참조하여 변경한다.
```
GRAYLOG_HOST="http://graylog.example.net"  GRAYLOG_ELASTICSEARCH_SHARDS=6 GRAYLOG_ELASTICSEARCH_REPLICAS=1 ./update_default_indexset.sh
```
