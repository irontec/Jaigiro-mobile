package com.irontec.jaigiro.models;

import java.text.ParseException;

import org.json.JSONException;
import org.json.JSONObject;

import com.irontec.jaigiro.helpers.DateUtils;

public class Ekintza {

	public Long id;
	public String izena;
	public String deskribapena;
	public String noiz;
	public String ordua;
	
	public Ekintza(Long id, String izena, String deskribapena, String noiz) {
		this.id = id;
		this.izena = izena;
		this.deskribapena = deskribapena;
		this.noiz = noiz;
	}
	
	public Ekintza() {
		this.id = -1l;
		this.izena = "";
		this.deskribapena = "";
		this.noiz = "";
		this.ordua = "";
	}
	
	public Ekintza(JSONObject object) throws JSONException {
		if (checkJsonField(object, "id")) {
			this.id = object.getLong("id");
		} else {
			this.id = 0l;
		}
		if (checkJsonField(object, "izena")) {
			this.izena = object.getString("izena");
		} else {
			this.izena = "";
		}
		if (checkJsonField(object, "deskribapena")) {
			this.deskribapena = object.getString("deskribapena");
		} else {
			this.deskribapena = "";
		}
		if (checkJsonField(object, "noiz")) {
			this.noiz = object.getString("noiz");
		} else {
			this.noiz = "";
		}
	}
	
	public Boolean checkJsonField(JSONObject json, String name) {
		if (json.has(name) && !json.isNull(name)) {
			return true;
		} else {
			return false;
		}
	}
	
	public String getFullDate() {
		return this.noiz + " " + this.ordua;
	}
	
	public String getEguna() throws ParseException {
		return DateUtils.getDayOfDate(this.noiz);
	}
	
	public String getOrdua() throws ParseException {
		return DateUtils.getHourOfDate(this.noiz);
	}
	
	public String getHilabetea() throws ParseException {
		return DateUtils.getMonthOfDateEuskaraz(this.noiz);
	}
}
