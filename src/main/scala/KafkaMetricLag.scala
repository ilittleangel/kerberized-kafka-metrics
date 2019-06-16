/**
  * Simple code to calculate Kafka LAG of
  * a specific topic and consumer group.
  */
import com.typesafe.config.ConfigFactory
import org.apache.kafka.clients.CommonClientConfigs
import org.apache.kafka.clients.consumer.{ConsumerConfig, KafkaConsumer}
import org.apache.kafka.common.TopicPartition
import org.apache.kafka.common.config.{SaslConfigs, SslConfigs}
import org.apache.kafka.common.serialization.ByteArrayDeserializer

import scala.collection.JavaConverters._


object KafkaMetricLag extends App {

  if (args.length < 2) {
    println("Usage: KafkaMetricLag <consumerGroup> <topicName>")
    System.exit(1)
  }

  val groupId = args(0)
  val topicName = args(1)

  val config = ConfigFactory.parseResources("kafka-config.conf")
    .getConfig("kafka_config")

  val kafkaParams = Map[String, Object](
    ConsumerConfig.GROUP_ID_CONFIG               -> groupId,
    ConsumerConfig.DEFAULT_API_TIMEOUT_MS_CONFIG -> "900000",
    CommonClientConfigs.SECURITY_PROTOCOL_CONFIG -> config.getString("security_protocol"),
    SaslConfigs.SASL_MECHANISM                   -> config.getString("sasl_mechanism"),
    SaslConfigs.SASL_KERBEROS_SERVICE_NAME       -> config.getString("sasl_kerberos_service_name"),
    SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG    -> config.getString("ssl_truststore_location"),
    SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG    -> config.getString("ssl_truststore_password"),

    "security.protocol" -> config.getString("security_protocol")
  )

  val consumer = new KafkaConsumer[Array[Byte], Array[Byte]](kafkaParams.asJava, new ByteArrayDeserializer, new ByteArrayDeserializer)
  val partitions = consumer.partitionsFor(topicName).asScala.map(partitionInfo => partitionInfo.partition())
  val topicPartitions = partitions.map(numPartition => new TopicPartition(topicName, numPartition))

  val endOffsets = consumer
    .endOffsets(topicPartitions.asJava)
    .asScala
    .map { case (topicPartition, endOffset) => topicPartition.partition() -> endOffset }

  val committedOffset = topicPartitions
    .map(topicPartition => topicPartition.partition() -> consumer.committed(topicPartition).offset())
    .toMap

  val lags = partitions.map(numPartition => numPartition -> (endOffsets(numPartition) - committedOffset(numPartition)))
  val accumLag = lags.map(_._2).sum
  val avgLag = accumLag.toDouble / partitions.size

  consumer.close()

  println(s"topics = ${consumer.listTopics().keySet()}")
  println(s"partitions: $partitions")
  println(s"topicPartitions: $topicPartitions")
  println(s"endOffsets: ${endOffsets.toSeq.sortBy(_._1).mkString("\n")}")
  println(s"accumLag = $accumLag")
  println(s"avgLag = $avgLag")

}
