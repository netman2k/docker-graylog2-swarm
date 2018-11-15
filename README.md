
## 사용방법
### 설정
Graylog가 접속할 MongoDB와 ElasticSearch URL을 수정한다.
설정파일은 env/common에 다음과 같이 존재한다.

```
GRAYLOG_DOMAIN="graylog.example.local"
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
### update_default_indexset.sh
기본으로 설정되어져있는 Default indexset 설정 변경 명령을 내리는 스크립트

다음은 graylog.example.net으로 서비스 중인 Graylog2가 사용 중인 ElasticSearch의 shard와 replicas 설정을 변경하는 방법을 보여준다.
그 외 기타 설정은 내부 스크립트 상당에 변수로 설정되어있으니 참조하여 변경한다.
```
export GRAYLOG_HOST="http://graylog.example.local"  
export GRAYLOG_ELASTICSEARCH_SHARDS=6 
export GRAYLOG_ELASTICSEARCH_REPLICAS=1 
./scripts/update_default_indexset.sh
```
### upload_contentpack.sh
Graylog 서버에 자신의 Contentpack을 API를 통하여 업로드하고 반영하는 스크립트

다음 경우, 생성해 놓은 Kafka를 통하여 syslog 토픽에 저장된 syslog를 처리하기 위해 만든 Contentpack을 등록해준다.
```
export GRAYLOG_HOST="http://graylog.example.local"  
./scripts/upload_contentpack.sh ./contentpack/kafka_syslog.json
```
