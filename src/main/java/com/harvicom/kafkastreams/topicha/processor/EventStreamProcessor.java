package com.harvicom.kafkastreams.topicha.processor;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Produced;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class EventStreamProcessor {

    @Value("${topicha.inputTopicName}")
    public String inputTopicName;

    @Value("${topicha.outputTopicName}")
    public String outputTopicName;

    @Autowired
    public void buildPipeline(StreamsBuilder streamsBuilder) {

        KStream<String, String> kStream = streamsBuilder.stream(inputTopicName,Consumed.with(Serdes.String(), Serdes.String()));
        kStream.to(outputTopicName,Produced.with(Serdes.String(), Serdes.String()));
    }
}
