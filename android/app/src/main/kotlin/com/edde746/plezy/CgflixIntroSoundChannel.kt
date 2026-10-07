package com.edde746.plezy

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * CGFLIX: toca o "tum" curto da abertura (res/raw/cgflix_intro.wav, gerado por
 * cgflix-brand/som/gerar_tum.py). Só toca com o aparelho no modo normal: no silencioso ou
 * no vibrar fica quieto. Responde `true` quando tocou.
 */
internal object CgflixIntroSoundChannel {
  private const val TAG = "CgflixIntroSound"
  private const val CHANNEL = "br.com.docaio.cgflix/intro_sound"

  fun register(messenger: BinaryMessenger, context: Context) {
    val appContext = context.applicationContext
    MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "play" -> result.success(play(appContext))
        else -> result.notImplemented()
      }
    }
  }

  private fun play(context: Context): Boolean {
    val audio = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return false
    if (audio.ringerMode != AudioManager.RINGER_MODE_NORMAL) return false
    return try {
      val player = MediaPlayer.create(
        context,
        R.raw.cgflix_intro,
        AudioAttributes.Builder()
          .setUsage(AudioAttributes.USAGE_MEDIA)
          .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
          .build(),
        audio.generateAudioSessionId(),
      ) ?: return false
      player.setOnCompletionListener { it.release() }
      player.start()
      true
    } catch (e: Exception) {
      Log.w(TAG, "som da abertura falhou", e)
      false
    }
  }
}
