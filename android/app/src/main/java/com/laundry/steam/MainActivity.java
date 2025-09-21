package com.laundry.steam;

//import io.flutter.embedding.android.FlutterActivity;
//
//public class MainActivity extends FlutterActivity {
//}
import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle; // Import Bundle

// For edge-to-edge compatibility
import androidx.core.view.WindowCompat; // Import WindowCompat
import androidx.core.view.WindowInsetsControllerCompat; // Import WindowInsetsControllerCompat
import android.view.View; // Import View

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Call EdgeToEdge.enable() BEFORE super.onCreate()
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false); // This makes the window edge-to-edge

        super.onCreate(savedInstanceState);
        // Your existing Flutter setup will follow here
    }
}