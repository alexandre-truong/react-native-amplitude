package com.otomogroove.ReactNativeAmplitude;

import android.content.res.AssetManager;
import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.ringdroid.soundfile.SoundFile;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;


/**
 * Created by juanjimenez on 13/01/2017.
 */

public class AmplitudeManager extends ReactContextBaseJavaModule {

    public static final String REACT_CLASS = "Amplitude";
    private SoundFile mSoundFile;
    private String tmpFile = "electric_theater_tmp.mp3";
    private Callback mCb;

    public AmplitudeManager(ReactApplicationContext reactContext) {

        super(reactContext);

    }


    @Override
    public String getName() {

        return REACT_CLASS;
    }

    public void hasSound(){
        try{

            WritableArray result;

            result = computeAmplitudeValues();
            mCb.invoke(result);

            String filePath = Environment.getExternalStorageDirectory().toString() + "/" + tmpFile;
            File f = new File(filePath);
            f.delete();

        }catch (Exception e){
                mCb.invoke("error : " + e);
                Log.d("AMPLITUDE", "ERROR DURING CALLBACK");
        }
    }

    @ReactMethod
    public void getAmplitudeValues(String fileName, Callback cb) {
        try{

            new DownloadFile().execute(fileName, tmpFile);
            mCb = cb;

        }catch (Exception e){
            cb.invoke("error : " + e);
        }
    }


    class DownloadFile extends AsyncTask<String, String, SoundFile> {


        /**
         * Before starting background thread Show Progress Bar Dialog
         * */
        @Override
        protected void onPreExecute() {
            super.onPreExecute();

        }

        /**
         * Downloading file in background thread
         * */
        @Override
        protected SoundFile doInBackground(String... f_url) {
            int count;
            String filePath;
            SoundFile soundFile = null;

            Log.d("AMPLITUDE", "f_url[0] : " + f_url[0]);

            AssetManager assetManager = getReactApplicationContext().getResources().getAssets();

            InputStream input = null;
            try {
                input = new BufferedInputStream(assetManager.open("audio/" + f_url[0]),
                        8192);
            } catch (IOException e) {
                e.printStackTrace();
            }

            filePath = Environment.getExternalStorageDirectory().toString() + "/" + tmpFile;
            OutputStream output = null;
            try {
                output = new FileOutputStream(filePath);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }

            try {

                byte data[] = new byte[1024];

                while ((count = input.read(data)) != -1) {

                    // writing data to file
                    output.write(data, 0, count);
                }

                // flushing output
                output.flush();

                // closing streams
                output.close();
                input.close();
                Log.e("XSXGOT","Audio file complented + "+filePath);

            } catch (Exception e) {
                Log.e("XSXGOT Error: ", e.getMessage());
                filePath = f_url[0];
            }

            try {
                soundFile = SoundFile.create(filePath,null);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (SoundFile.InvalidInputException e) {
                e.printStackTrace();
            }

            return soundFile;
        }

        /**
         * Updating progress bar
         * */
        protected void onProgressUpdate(String... progress) {
            // setting progress percentage

        }



        /**
         * After completing background task Dismiss the progress dialog
         * **/
        @Override
        protected void onPostExecute(SoundFile soundFile) {
            // dismiss the dialog after the file was downloaded
            if(soundFile!=null) {
                Log.d("AMPLITUDE","" + soundFile.getNumFrames());
                mSoundFile = soundFile;
                hasSound();
            }else{
                Log.e("AMPLITUDE","soundfile is null");
            }

        }

    }

    public WritableArray computeAmplitudeValues() {
        if(mSoundFile == null)
            Log.e("AMPLITUDE", "Global variable mSoundFile is NULL...");

        WritableArray result = new WritableNativeArray();
        int numFrames = mSoundFile.getNumFrames();
        int[] frameGains = mSoundFile.getFrameGains();
        for (int i = 0; i < numFrames - 1; i++) {
//            Log.d("AMPLITUDE VALUES", "" + frameGains[i]);
            result.pushDouble(frameGains[i]);
        }

        return result;
    }

}
