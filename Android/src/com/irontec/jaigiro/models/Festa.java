package com.irontec.jaigiro.models;

import java.text.ParseException;

import org.json.JSONException;
import org.json.JSONObject;

import com.irontec.jaigiro.helpers.DateUtils;

import android.os.Parcel;
import android.os.Parcelable;

public class Festa  implements Parcelable {
 
	public Long id;
	public String izena;
	public String deskribapena;
	public String herria;
	public Double lat;
	public Double lng;
	public String hasiera;
	public String bukaera;
	public Long pisua;
	public Boolean banator;
	public String kartela;
	public String thumb;
	public int color;
	
	public Festa() {
		super();
		this.id = 0l;
		this.izena = "";
		this.deskribapena = "";
		this.herria = "";
		this.lat = 0d;
		this.lng = 0d;
		this.hasiera = "";
		this.bukaera = "";
		this.pisua = 0l;
		this.banator = false;
		this.kartela = "";
		this.thumb = "";
		this.color = 0;
	}
	
	public Festa(JSONObject object) throws JSONException {
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
		if (checkJsonField(object, "herria")) {
			this.herria = object.getString("herria");
		} else {
			this.herria = "";
		}
		if (checkJsonField(object, "lat")) {
			this.lat = object.getDouble("lat");
		} else {
			this.lat = 0d;
		}
		if (checkJsonField(object, "lng")) {
			this.lng = object.getDouble("lng");
		} else {
			this.lng = 0d;
		}
		if (checkJsonField(object, "hasiera")) {
			this.hasiera = object.getString("hasiera");
		} else {
			this.hasiera = "";
		}
		if (checkJsonField(object, "bukaera")) {
			this.bukaera = object.getString("bukaera");
		} else {
			this.bukaera = "";
		}
		if (checkJsonField(object, "pisua")) {
			this.pisua = object.getLong("pisua");
		} else {
			this.pisua = 0l;
		}
		if (checkJsonField(object, "banator")) {
			this.banator = object.getBoolean("banator");
		} else {
			this.banator = false;
		}
		if (checkJsonField(object, "kartela")) {
			this.kartela = object.getString("kartela");
		} else {
			this.kartela = "";
		}
		if (checkJsonField(object, "thumb")) {
			this.thumb = object.getString("thumb");
		} else {
			this.thumb = "";
		}
	}
	
	public String getEguna() throws ParseException {
		return DateUtils.getDayOfDate(this.hasiera);
	}
	
	public String getOrdua() throws ParseException {
		return DateUtils.getHourOfDate(this.hasiera);
	}
	
	public String getHilabetea() throws ParseException {
		return DateUtils.getMonthOfDateEuskaraz(this.hasiera);
	}
	
	public Boolean checkJsonField(JSONObject json, String name) {
		if (json.has(name) && !json.isNull(name)) {
			return true;
		} else {
			return false;
		}
	}

	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		
		dest.writeLong(id);
		dest.writeString(izena);
		dest.writeString(deskribapena);
		dest.writeString(herria);
		dest.writeDouble(lat);
		dest.writeDouble(lng);
		dest.writeString(hasiera);
		dest.writeString(izena);
		dest.writeString(bukaera);
		dest.writeDouble(pisua);
		dest.writeByte((byte) (banator ? 1 : 0));
		dest.writeString(kartela);
		dest.writeString(thumb);
		dest.writeInt(color);
	}

	public static final Parcelable.Creator<Festa> CREATOR
	= new Parcelable.Creator<Festa>() {
		public Festa createFromParcel(Parcel in) {
			return new Festa(in);
		}

		public Festa[] newArray(int size) {
			return new Festa[size];
		}
	};

	private Festa(Parcel in) {
		id = in.readLong();
		izena = in.readString();
		deskribapena = in.readString();
		herria = in.readString();
		lat = in.readDouble();
		lng = in.readDouble();
		hasiera = in.readString();
		izena = in.readString();
		bukaera = in.readString();
		pisua = in.readLong();
		banator = in.readByte() == 1;
		kartela = in.readString();
		thumb = in.readString();
		color = in.readInt();
	}

}
