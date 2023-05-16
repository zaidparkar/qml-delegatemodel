package com.example.contactsPicker;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.qtproject.qt.android.bindings.QtActivity;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends QtActivity {

    private static final int PERMISSIONS_REQUEST_CODE = 105;

    public native void getContactsJNI(String contactsJson);

    private void requestAppPermissions() {
        String[] permissions = new String[]{
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.WRITE_CONTACTS
        };
        boolean permissionsGranted = true;
        for (String permission : permissions) {
            if (checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                permissionsGranted = false;
                break;
            }
        }
        if (!permissionsGranted) {
            requestPermissions(permissions, PERMISSIONS_REQUEST_CODE);
        }
    }



    public void getContacts() {
        List<JSONObject> contactsList = new ArrayList<>();
        String[] projection = new String[]{
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER
        };
        String sortOrder = ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC";

        Cursor cursor = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            cursor = getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, projection,
                    null, null, sortOrder);
        }

        if (cursor != null) {
            while (cursor.moveToNext()) {
                @SuppressLint("Range") String name = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
                @SuppressLint("Range") String number = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));

                JSONObject contact = new JSONObject();

                try {
                    contact.put("name",name);
                    contact.put("number",number);
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }

                contactsList.add(contact);
            }
            cursor.close();
        }

        JSONArray contactsArray = new JSONArray(contactsList);
        String contactsJsonString = contactsArray.toString();

        getContactsJNI(contactsJsonString);
    }


    public void callGetContacts() {
        getContacts();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestAppPermissions();
    }
}
