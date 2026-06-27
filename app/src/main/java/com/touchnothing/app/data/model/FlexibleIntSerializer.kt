package com.touchnothing.app.data.model

import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.longOrNull

object FlexibleIntSerializer : KSerializer<Int> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("FlexibleInt", PrimitiveKind.INT)

    override fun deserialize(decoder: Decoder): Int {
        val jsonDecoder = decoder as? JsonDecoder ?: return decoder.decodeInt()
        return decodeFlexibleInt(jsonDecoder.decodeJsonElement())
    }

    override fun serialize(encoder: Encoder, value: Int) {
        encoder.encodeInt(value)
    }

    fun decodeFlexibleInt(element: JsonElement): Int {
        if (element !is JsonPrimitive) {
            throw IllegalArgumentException("Expected primitive")
        }
        return element.intOrNull
            ?: element.longOrNull?.toInt()
            ?: element.content.toIntOrNull()
            ?: throw IllegalArgumentException("Expected numeric value")
    }
}
