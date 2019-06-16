name := "KafkaMetrics"

version := "0.1"

scalaVersion := "2.12.7"

libraryDependencies ++= Seq(
  "org.scala-lang" % "scala-reflect" % scalaVersion.value,
  "org.apache.kafka" % "kafka-clients" % "2.1.0",
  "com.typesafe" % "config" % "1.3.2"
)
