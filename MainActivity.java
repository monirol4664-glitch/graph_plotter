package com.example.attendance;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private EditText nameInput;
    private TextView statusDisplay;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Requires: res/layout/activity_main.xml with @+id/nameInput, statusDisplay, presentBtn, absentBtn
        setContentView(R.layout.activity_main);

        nameInput = findViewById(R.id.nameInput);
        statusDisplay = findViewById(R.id.statusDisplay);
        Button presentBtn = findViewById(R.id.presentBtn);
        Button absentBtn = findViewById(R.id.absentBtn);

        prefs = getSharedPreferences("AttendanceData", MODE_PRIVATE);
        loadLastRecord();

        presentBtn.setOnClickListener(v -> markAttendance("Present"));
        absentBtn.setOnClickListener(v -> markAttendance("Absent"));
    }

    private void markAttendance(String status) {
        String name = nameInput.getText().toString().trim();
        if (name.isEmpty()) {
            Toast.makeText(this, "Please enter a name", Toast.LENGTH_SHORT).show();
            return;
        }
        String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());
        String record = name + " | " + status + " | " + timestamp;

        prefs.edit().putString("lastRecord", record).apply();
        statusDisplay.setText(record);
        Toast.makeText(this, "✅ Attendance recorded: " + status, Toast.LENGTH_SHORT).show();
    }

    private void loadLastRecord() {
        String record = prefs.getString("lastRecord", "No records yet");
        statusDisplay.setText(record);
    }
}