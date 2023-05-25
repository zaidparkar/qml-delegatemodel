package com.example.contactsPicker;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.ContentProviderOperation;
import android.content.OperationApplicationException;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.RemoteException;
import android.provider.ContactsContract;
import android.util.Log;
import android.widget.Toast;
import android.database.ContentObserver;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.qtproject.qt.android.bindings.QtActivity;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends QtActivity {

    private static final int PERMISSION_REQUEST_CODE = 1;
    private static final int CONTACTS_TO_CREATE = 10;
    private boolean PERMISSIONS = true;
    private ContentObserver contactObserver;
    public String lastTimeSync = "0";
    public String deleteTimeSync = "0";

    ExecutorService executor = Executors.newFixedThreadPool(1);

    public Runnable modifiedRunnable = new Runnable() {
        @Override
        public void run() {
            JSONObject updatedContact = getUpdatedContact();
            if(updatedContact!=null)
                updateContactJNI(updatedContact.toString());
        }
    };

    public Runnable deletedRunnable = new Runnable() {
        @Override
        public void run() {
            List<String> deletedContactID = getDeletedContact();
            if(deletedContactID != null) {
                deleteContactJNI(deletedContactID);
            }
        }
    };

    public Runnable getContactsRunnable = new Runnable() {
        @Override
        public void run() {
            List<JSONObject> contactsList = getFullContacts();

            JSONArray contactsArray = new JSONArray(contactsList);
            String contactsJsonString = contactsArray.toString();

            getContactsJNI(contactsJsonString);
        }
    };
    public Runnable createContactsRunnable = new Runnable() {
        @Override
        public void run() {
            createContacts();
        }
    };


    public native void getContactsJNI(String contactsJson);
    public native void updateContactJNI(String contactJson);
    public native void deleteContactJNI(List<String> contactID);

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
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
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
                @SuppressLint("Range") String id = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID));
                @SuppressLint("Range") String name = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
                @SuppressLint("Range") String number = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));

                JSONObject contact = new JSONObject();

                try {
                    contact.put("id",id);
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
        executor.submit(getContactsRunnable);
    }

    public String generateRandomName() {
        Random random = new Random();
        StringBuilder name = new StringBuilder();
        int length = random.nextInt(5) + 5; // Random name length between 5 and 10 characters

        for (int i = 0; i < length; i++) {
            char randomChar;
            if (i == 0) {
                randomChar = (char) (random.nextInt(26) + 'A'); // Random uppercase letter for the first character
            } else {
                randomChar = (char) (random.nextInt(26) + 'a'); // Random lowercase letter for the remaining characters
            }
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
            int contactsNeeded = CONTACTS_TO_CREATE - allContacts.size();
            ExecutorService executor = Executors.newFixedThreadPool(contactsNeeded);
            List<Callable<Void>> tasks = new ArrayList<>();

            for(int i=allContacts.size(); i<CONTACTS_TO_CREATE; i++) {
                Callable<Void> task = () -> {

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
                            .withValue(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, "" + name)
                            .build());

                    // Adding Number
                    cpo.add(ContentProviderOperation
                            .newInsert(ContactsContract.Data.CONTENT_URI)
                            .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                            .withValue(ContactsContract.Data.MIMETYPE,
                                    ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                            .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, "" + number)
                            .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,
                                    ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
                            .build());
                    try {
                        getContentResolver().applyBatch(ContactsContract.AUTHORITY, cpo);
                    } catch (OperationApplicationException | RemoteException e) {
                        e.printStackTrace();
                    }
                    return null;
                };
                tasks.add(task);
            }
            try {
                executor.invokeAll(tasks);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            executor.shutdown();
        }
    }

    public void updateContacts(String id, String newName, String newNumber) {

        ArrayList<ContentProviderOperation> cpo = new ArrayList<>();

//      update number
        cpo.add(ContentProviderOperation
                .newUpdate(ContactsContract.Data.CONTENT_URI)
                .withSelection(ContactsContract.Data.CONTACT_ID + " = ?",new String[] {id})
                .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER,""+newNumber)
                .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
                .build());

//      update name
        cpo.add(ContentProviderOperation
                .newUpdate(ContactsContract.Data.CONTENT_URI)
                .withSelection(ContactsContract.Data.CONTACT_ID + " = ? AND " +
                        ContactsContract.Data.MIMETYPE + " = ?",new String[] {id, ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE})
                .withValue(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,""+newName)
                .build());

        try {
            getContentResolver().applyBatch(ContactsContract.AUTHORITY, cpo);
        } catch (OperationApplicationException | RemoteException e) {
            e.printStackTrace();
        }
    }

    public void deleteContactFromPhone(String id) {

        ArrayList<ContentProviderOperation> cpo = new ArrayList<>();

        cpo.add(ContentProviderOperation
                .newDelete(ContactsContract.RawContacts.CONTENT_URI)
                .withSelection(ContactsContract.RawContacts.CONTACT_ID + " = ?",new String[] {id})
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

    private void registerContactObserver() {
        contactObserver = new ContentObserver(new Handler()) {
            @Override
            public void onChange(boolean selfChange, Uri uri) {
                super.onChange(selfChange, uri);
                executor.submit(modifiedRunnable);
                executor.submit(deletedRunnable);
            }
        };
        getContentResolver().registerContentObserver(
                ContactsContract.Contacts.CONTENT_URI,
                true,
                contactObserver
        );
    }
    private JSONObject getUpdatedContact() {
        String[] projection = new String[]{
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER,
                ContactsContract.CommonDataKinds.Phone.CONTACT_LAST_UPDATED_TIMESTAMP
        };

        Cursor cursor = getContentResolver().query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                projection,
                ContactsContract.CommonDataKinds.Phone.CONTACT_LAST_UPDATED_TIMESTAMP + " > ?",
                new String[]{lastTimeSync},
                null
        );

        lastTimeSync = String.valueOf(System.currentTimeMillis());

        JSONObject contact = null;

        if (cursor != null && cursor.moveToFirst()) {
            @SuppressLint("Range") String id = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID));
            @SuppressLint("Range") String name = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
            @SuppressLint("Range") String number = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));

            contact = new JSONObject();
            try {
                contact.put("id", id);
                contact.put("name", name);
                contact.put("number", number);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            cursor.close();
        }

        return contact;
    }

    @SuppressLint("Range")
    private List<String> getDeletedContact() {

        List<String> deletedContacts = new ArrayList<>();

        String[] projection = new String[]{
                ContactsContract.DeletedContacts.CONTACT_ID
        };

        Cursor cursor = getContentResolver().query(
                ContactsContract.DeletedContacts.CONTENT_URI,
                projection,
                ContactsContract.DeletedContacts.CONTACT_DELETED_TIMESTAMP + " > ?",
                new String[]{deleteTimeSync},
                null
        );

        String contactID = null;
        if (cursor != null) {
            while(cursor.moveToNext()) {
                contactID = cursor.getString(cursor.getColumnIndex(ContactsContract.DeletedContacts.CONTACT_ID));
                deletedContacts.add(contactID);
            }
        }
        if (cursor != null) {
            cursor.close();
        }
        deleteTimeSync = String.valueOf(System.currentTimeMillis());
        return deletedContacts;
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
        executor.submit(createContactsRunnable);
        lastTimeSync = String.valueOf(System.currentTimeMillis());
        deleteTimeSync = String.valueOf(System.currentTimeMillis());
        registerContactObserver();
    }

    protected void onDestroy() {
        super.onDestroy();
        getContentResolver().unregisterContentObserver(contactObserver);
    }
}
