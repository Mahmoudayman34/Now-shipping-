package co.nowshipping.nowshipping

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "co.nowshipping.nowshipping/opengl"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Suppress OpenGL ES debug logs
        System.setProperty("log.tag.libEGL", "ERROR")
        System.setProperty("log.tag.EGL_emulation", "ERROR")
        System.setProperty("log.tag.GLSurfaceView", "ERROR")
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "suppressOpenGLLogs" -> {
                    suppressOpenGLLogs()
                    result.success("OpenGL logs suppressed")
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun suppressOpenGLLogs() {
        // Additional OpenGL ES log suppression
        Log.d("MainActivity", "Suppressing OpenGL ES debug logs")
    }
}
