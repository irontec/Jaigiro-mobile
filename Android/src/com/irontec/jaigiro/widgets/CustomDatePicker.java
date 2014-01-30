package com.irontec.jaigiro.widgets;

import java.util.Calendar;
import java.util.Locale;

import android.app.DatePickerDialog;
import android.content.Context;
import android.widget.DatePicker;

public class CustomDatePicker extends DatePickerDialog {

	private CharSequence title;
	private Locale locale;

    public CustomDatePicker(Context context, OnDateSetListener callBack, int year, int monthOfYear, int dayOfMonth, Locale loc) {
        super(context, callBack, year, monthOfYear, dayOfMonth);
        this.locale = loc;
    }

    public void setPermanentTitle(CharSequence title) {
        this.title = title;
        setTitle(title);
    }

    @Override
    public void onDateChanged(DatePicker view, int year, int month, int day) {
        super.onDateChanged(view, year, month, day);
        setTitle(title);
    }
    
    @Override
    public void updateDate(int year, int monthOfYear, int dayOfMonth) {
    	super.updateDate(year, monthOfYear, dayOfMonth);
    	
    	Calendar cal = Calendar.getInstance(locale);
    	cal.set(Calendar.YEAR, year);
    	cal.set(Calendar.MONTH, monthOfYear);
    	cal.set(Calendar.DAY_OF_MONTH, dayOfMonth);
    	
    	
    }
    
}