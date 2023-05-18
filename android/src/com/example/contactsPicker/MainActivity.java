package com.example.contactsPicker;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.ContentProviderOperation;
import android.content.OperationApplicationException;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.os.Bundle;
import android.os.RemoteException;
import android.provider.ContactsContract;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.qtproject.qt.android.bindings.QtActivity;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class MainActivity extends QtActivity {

    private static final int PERMISSION_REQUEST_CODE = 1;
    private static final int CONTACTS_TO_CREATE = 50;
    private boolean PERMISSIONS = true;

    public native void getContactsJNI(String contactsJson);

    private void requestAppPermissions() {
        String[] permissions = new String[]{
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.WRITE_CONTACTS
        };
        for (String permission : permissions) {
            if (checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                PERMISSIONS = false;
                break;
            }
        }
        if (!PERMISSIONS) {
            requestPermissions(permissions, PERMISSION_REQUEST_CODE);
        }
    }

    public List<JSONObject> getFullContacts() {
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
        return contactsList;
    }

    public void getContacts() {
        List<JSONObject> contactsList = getFullContacts();

        JSONArray contactsArray = new JSONArray(contactsList);
        String contactsJsonString = contactsArray.toString();

        getContactsJNI(contactsJsonString);
    }

    public String generateRandomName() {
        Random random = new Random();
        StringBuilder name = new StringBuilder();
        int length = random.nextInt(5) + 5; // Random name length between 5 and 10 characters

        for (int i = 0; i < length; i++) {
            char randomChar = (char) (random.nextInt(26) + 'a'); // Random lowercase letter
            name.append(randomChar);
        }

        return name.toString();
    }

    public String randomPhoneNumber() {
        Random random = new Random();
        StringBuilder phoneNumber = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            int digit = random.nextInt(10);
            phoneNumber.append(digit);
        }
        return phoneNumber.toString();
    }

    public void createContacts() {

        List<JSONObject> allContacts = getFullContacts();
        if(!(allContacts.size() >= CONTACTS_TO_CREATE)) {
            for(int i=0; i<CONTACTS_TO_CREATE; i++){
                String name = generateRandomName();
                String number = randomPhoneNumber();
                ArrayList<ContentProviderOperation> cpo
                        = new ArrayList<>();

                cpo.add(ContentProviderOperation.newInsert(
                                ContactsContract.RawContacts.CONTENT_URI)
                        .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, null)
                        .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, null)
                        .build());

                // Adding Name
                cpo.add(ContentProviderOperation
                        .newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                        .withValue(ContactsContract.Data.MIMETYPE,
                                ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                        .withValue(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, ""+name)
                        .build());

                // Adding Number
                cpo.add(ContentProviderOperation
                        .newInsert(ContactsContract.Data.CONTENT_URI)
                        .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                        .withValue(ContactsContract.Data.MIMETYPE,
                                ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                        .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, ""+number)
                        .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,
                                ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
                        .build());
                try {
                    getContentResolver().applyBatch(ContactsContract.AUTHORITY, cpo);
                } catch (OperationApplicationException | RemoteException e) {
                    e.printStackTrace();
                }
            }
        }

    }

    public void updateContacts(String oldName, String oldNumber, String newName, String newNumber) {

        ArrayList<ContentProviderOperation> cpo = new ArrayList<>();

        // update number
        cpo.add(ContentProviderOperation
                .newUpdate(ContactsContract.Data.CONTENT_URI)
                .withSelection(ContactsContract.Data.DISPLAY_NAME + " = ? AND " +
                        ContactsContract.Data.MIMETYPE + " = ? AND " + ContactsContract.CommonDataKinds.Phone.NUMBER + " = ?"
                        ,new String[] {oldName, ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE,oldNumber})
                .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER,""+newNumber)
                .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
                .build());

        // update name
        cpo.add(ContentProviderOperation
                .newUpdate(ContactsContract.Data.CONTENT_URI)
                .withSelection(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME + " = ? AND " +
                        ContactsContract.Data.MIMETYPE + " = ?",new String[] {oldName, ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE})
                .withValue(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,""+newName)
                .build());

        try {
            getContentResolver().applyBatch(ContactsContract.AUTHORITY, cpo);
        } catch (OperationApplicationException | RemoteException e) {
            e.printStackTrace();
        }
    }

    public void deleteContactFromPhone(String name, String number) {

        ArrayList<ContentProviderOperation> cpo = new ArrayList<>();

        cpo.add(ContentProviderOperation.newDelete(ContactsContract.RawContacts.CONTENT_URI)
                .withSelection(ContactsContract.RawContacts.DISPLAY_NAME_PRIMARY + " = ?",new String[]{name})
                .build());

        try {
            getContentResolver().applyBatch(ContactsContract.AUTHORITY, cpo);
        } catch (OperationApplicationException | RemoteException e) {
            e.printStackTrace();
        }
}
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestAppPermissions();
        if(PERMISSIONS) {
            performActionAfterPermissionGranted();
        }
        else {
            requestAppPermissions();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                performActionAfterPermissionGranted();
            }
            else {
                Toast.makeText(this, "Permission needed to Proceed", Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void performActionAfterPermissionGranted() {
        createContacts();
    }

    protected void onDestroy() {
        super.onDestroy();
    }
}
