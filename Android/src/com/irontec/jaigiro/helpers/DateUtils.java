package com.irontec.jaigiro.helpers;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import android.annotation.SuppressLint;
import android.util.Log;

public class DateUtils {

	private static final String TAG = DateUtils.class.getSimpleName();

	public static String preformatDate(Long millis) {
		DateTime date = new DateTime(millis);
		DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd");
		return date.toString(fmt);
	}
	
	public static String preformatDate(Date date) {
		DateTime datetime = new DateTime(date);
		DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd");
		return datetime.toString(fmt);
	}

	@SuppressLint("SimpleDateFormat")
	public static String prettify(String start, String end) throws ParseException {

		String result = "";

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Date startLocal, endLocal;
		startLocal = sdf.parse(start);
		endLocal = sdf.parse(end);

		DateTime startDateTime = new DateTime(startLocal);
		DateTime endDateTime = new DateTime(endLocal);

		// result = startDateTime.getYear() + "ko ";
		result += integerToHilabeteaEuskaraz(startDateTime.getMonthOfYear());
		result += startDateTime.getDayOfMonth()+"-(e)tik ";

		if (startDateTime.getYear() != endDateTime.getYear()) {
			result += endDateTime.getYear() + "ko ";
			result += integerToHilabeteaEuskaraz(endDateTime.getMonthOfYear());
			result += endDateTime.getDayOfMonth()+"-(e)ra";
		} else {
			if (startDateTime.getMonthOfYear() != endDateTime.getMonthOfYear()) {
				result += integerToHilabeteaEuskaraz(endDateTime.getMonthOfYear());
			}
			result += endDateTime.getDayOfMonth()+"-(e)ra";
		}

		return result;
	}
	
	@SuppressLint("SimpleDateFormat")
	public static String prettify(String date) throws ParseException {

		String result = "";
		String hour = "";

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		Date dateLocal;
		dateLocal = sdf.parse(date);

		DateTime dateTime = new DateTime(dateLocal);

		result += integerToHilabeteaEuskaraz(dateTime.getMonthOfYear());
		result += dateTime.getDayOfMonth()+"-(e)an ";
		result += dateTime.getHourOfDay() + ":" + String.format("%02d", dateTime.getMinuteOfHour() ) + "-(e)tan ";

		return result;
	}
	
	public static String getDayOfDate(String date) throws ParseException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Date dateLocal;
		dateLocal = sdf.parse(date);
		
		DateTime dateTime = new DateTime(dateLocal);
		
		return String.valueOf(dateTime.getDayOfMonth());
	}
	
	public static String getMonthOfDateEuskaraz(String date) throws ParseException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		Date dateLocal;
		dateLocal = sdf.parse(date);
		
		DateTime dateTime = new DateTime(dateLocal);
		
		return integerToHilabeteaEuskarazSimple(dateTime.getMonthOfYear());
	}
	
	public static String getHourOfDate(String date) throws ParseException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		Date dateLocal;
		dateLocal = sdf.parse(date);
		
		DateTime dateTime = new DateTime(dateLocal);
		
		return dateTime.getHourOfDay() + ":" + String.format("%02d", dateTime.getMinuteOfHour() );
	}

	private static String integerToHilabeteaEuskaraz(int month) {
		switch (month) {
		case 1:
			return "Urtarrilaren ";
		case 2:
			return "Otsailaren ";
		case 3:
			return "Martxoaren ";
		case 4:
			return "Apirilaren ";
		case 5:
			return "Maiatzaren ";
		case 6:
			return "Ekainaren ";
		case 7:
			return "Uztailaren ";
		case 8:
			return "Abuztuaren ";
		case 9:
			return "Irailaren ";
		case 10:
			return "Urriaren ";
		case 11:
			return "Azaroaren ";
		case 12:
			return "Abenduaren ";
		default:
			return null;
		}
	}
	
	private static String integerToHilabeteaEuskarazSimple(int month) {
		switch (month) {
		case 1:
			return "Urtarrila";
		case 2:
			return "Otsaila";
		case 3:
			return "Martxoa";
		case 4:
			return "Apirila";
		case 5:
			return "Maiatza";
		case 6:
			return "Ekaina";
		case 7:
			return "Uztaila";
		case 8:
			return "Abuztua";
		case 9:
			return "Iraila";
		case 10:
			return "Urria";
		case 11:
			return "Azaroa";
		case 12:
			return "Abendua";
		default:
			return null;
		}
	}

}
