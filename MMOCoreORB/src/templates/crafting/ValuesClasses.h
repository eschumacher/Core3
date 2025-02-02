/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

#ifndef VALUESCLASSES_H_
#define VALUESCLASSES_H_

#include "system/lang.h"
#include "engine/log/Logger.h"

/*
 * The Values class is just a container for values calculated in crafting
 * Each "Value" has 3 properties, maxPercentage, currentPercentage, currentValue.
 * These values coupled with the traits minValue and maxValue allow a generic holder for
 * whatever value the crafting process needs on any range
 */
class Values : public Object {
	VectorMap<String, float> values;
	String name;
	float minValue, maxValue;
	short precision;
	short combineType;
	bool locked;
	bool experimentalProperties;

public:
	Values() = delete;

	Values(const String& n, const float& tempmin, const float& tempmax, const int& prec, const bool& filler, const int& combine) {
		name = n;

		minValue = tempmin;
		maxValue = tempmax;
		precision = prec;

		locked = false;

		values.put("maxPercentage", 0.0f);
		values.put("currentPercentage", 0.0f);
		values.put("currentValue", 0.0f);

		experimentalProperties = filler;
		combineType = combine;
	}

	Values(const Values& val) : Object() {
		values = val.values;
		name = val.name;
		minValue = val.minValue;
		maxValue = val.maxValue;
		precision = val.precision;
		locked = val.locked;
		experimentalProperties = val.experimentalProperties;
		combineType = val.combineType;
	}

	Values(Values&& val) : Object(), values(std::move(val.values)),
					  name(std::move(val.name)), minValue(val.minValue),
					  maxValue(val.maxValue), precision(val.precision),
	      				  combineType(val.combineType), locked(val.locked),
					  experimentalProperties(val.experimentalProperties) {
	}

	~Values(){
	}

	inline float getPercentage() const {
		return values.get("currentPercentage");
	}

	inline float getValue() const {
		return values.get("currentValue");
	}

	inline float getMaxPercentage() const {
		return values.get("maxPercentage");
	}

	inline float getMinValue() const {
		return minValue;
	}

	inline float getMaxValue() const {
		return maxValue;
	}

	inline int getPrecision() const {
		return precision;
	}

	inline bool isFiller() const {
		return experimentalProperties;
	}

	inline void setFiller(bool in) {
		experimentalProperties = in;
	}

	inline const String& getName() const {
		return name;
	}

	inline short getCombineType() const {
		return combineType;
	}

	inline void lockValue() {
		//minValue = getValue();
		//maxValue = getValue();
		locked = true;
	}

	inline void unlockValue() {
		// why did this reset the values? that doesnt make sense locking it should freeze it not change it.
		//minValue = getValue();
		//maxValue = getValue();
		locked = false;
	}

	inline void setValue(const float& value) {
		if (locked)
			return;

		float newpercentage;

		if (Float::areAlmostEqualRelative(maxValue, minValue)) {
			newpercentage = (value - minValue);

			const static Logger logger("ValuesClasses");

			logger.warning() << name << " value class has the same maxValue and minValue that are equal to: " << maxValue;
		} else if (maxValue > minValue) {
			newpercentage = (value - minValue) / (maxValue - minValue);
		} else {
			newpercentage = 1 - ((value - maxValue) / (minValue - maxValue));
		}

		if (newpercentage > values.get("maxPercentage"))
			newpercentage = values.get("maxPercentage");

		if (newpercentage < 0)
			newpercentage = 0;

		if (values.contains("currentValue")) {
			values.drop("currentValue");
		}

		if (values.contains("currentPercentage")) {
			values.drop("currentPercentage");
		}

		values.put("currentValue", value);
		values.put("currentPercentage", newpercentage);
	}

	inline void setMinValue(const float& value) {
		if (locked)
			return;
		minValue = value;
	}

	inline void setMaxValue(const float& value) {
		if (locked)
			return;
		maxValue = value;
	}

	inline void setPrecision(const int& value) {
		if (locked)
			return;

		if(value < 0)
			return;

		precision = value;
	}

	inline void setMaxPercentage(float& value) {
		if (locked)
			return;

		if(value > 100)
			value = 100;

		if(value < 0)
			value = 0;

		if (values.contains("maxPercentage")) {
			values.drop("maxPercentage");
		}

		values.put("maxPercentage", value);
	}

	inline void setPercentage(float& value) {

		if (locked)
			return;

		if(value > values.get("maxPercentage"))
			value = values.get("maxPercentage");

		if(value < 0)
			value = 0;

		if (values.contains("currentPercentage")) {
			values.drop("currentPercentage");
		}

		values.put("currentPercentage", value);
	}
	inline void resetValue() {
		float reset = (getMaxPercentage() * 10.0f) * (0.000015f * (getMaxPercentage() * 10.0f) + 0.015f);
		setPercentage(reset);

		float newvalue;
		if (maxValue > minValue)
			newvalue = (reset * (maxValue - minValue)) + minValue;
		else
			newvalue = ((1.0f - reset) * (minValue - maxValue)) + maxValue;
		setValue(newvalue);
	}

};

class Subclasses : public Object {
	VectorMap<String, Reference<Values*> > valueList;
	float avePercentage;
	String name, classTitle;

	bool hidden;

public:
	Subclasses() = delete;

	Subclasses(const String& title, const String& subtitle, const float
			min, const float max, const int precision, const bool filler, const int combine) {

		classTitle = title;

		name = subtitle;

		Values* values = new Values(subtitle, min, max, precision, filler, combine);

		valueList.setNullValue(nullptr);
		valueList.put(subtitle, values);

		if (classTitle == "null" || classTitle == "" || (name == "")) {
			hidden = true;
		} else
			hidden = false;

		avePercentage = 0;
	}

	Subclasses(const Subclasses& sub) : Object() {
		hidden = sub.hidden;
		name = sub.name;
		classTitle = sub.classTitle;
		avePercentage = sub.avePercentage;

		for (int i = 0; i < sub.valueList.size(); ++i) {
			const auto& entry = sub.valueList.elementAt(i);

			Values* values = entry.getValue();

			Values* newvalues = new Values(*values);

			valueList.put(entry.getKey(), newvalues);
		}
	}

	Subclasses(Subclasses&& sub) : Object(), valueList(std::move(sub.valueList)),
					avePercentage(sub.avePercentage), name(std::move(sub.name)),
					classTitle(std::move(sub.classTitle)), hidden(sub.hidden) {
	}

	~Subclasses(){
	}

	void addSubtitle(const String& s, const float min, const float max, const int precision, const bool filler, const int combine) {

		if (valueList.contains(s)) {
			Values* value = valueList.get(s);

			valueList.drop(s);
		}

		Values* values = new Values(s, min, max, precision, filler, combine);
		valueList.put(s, values);
	}

	inline const Values* get(const int i) const {
		return valueList.get(i);
	}

	inline Values* get(const int i) {
		return valueList.get(i);
	}

	inline Values* get(const String& subTitle) {
		return valueList.get(subTitle);
	}

	inline const Values* get(const String& subTitle) const {
		return valueList.get(subTitle);
	}

	inline int size() const {
		return valueList.size();
	}

	inline bool isClassHidden() const {
		return hidden;
	}

	inline bool hasAllHiddenItems() const {
		for(int i = 0; i < valueList.size(); ++i) {
			auto values = valueList.get(i);
			if(!values->isFiller() && values->getMaxValue() != values->getMinValue())
				return false;
		}
		return true;
	}

	inline float getPercentage(const String& subTitle) const {
		auto values = valueList.get(subTitle);
		return values->getPercentage();
	}

	inline float getMaxPercentage(const String& subTitle) const {
		auto values = valueList.get(subTitle);
		return values->getMaxPercentage();
	}

	inline float getValue(const String& subTitle) const {
		auto values = valueList.get(subTitle);
		return values->getValue();
	}

	//inline String& getName() {
	//	return name;
	//}

	inline const String& getClassTitle() const {
		return classTitle;
	}

	inline void setMaxPercentage(const String& subtitle, float value) {
		Values* values = valueList.get(subtitle);
		values->setMaxPercentage(value);

	}

	inline void setValue(const String& subtitle, const float value) {
		Values* values = valueList.get(subtitle);
		values->setValue(value);
	}

	inline void setPercentage(const String& subtitle, float value) {
		Values* values = valueList.get(subtitle);
		values->setPercentage(value);
	}

	String toString() {
		Values* tempValues;

		StringBuffer str;

		for (int i = 0;i < valueList.size(); ++i) {

			tempValues = valueList.get(i);

			str << "Property Name: " << tempValues->getName();

			if(tempValues->isFiller()) {
				str << " HIDDEN" << endl;
			} else {
				str << endl;
			}

			str << "Max % " << tempValues->getMaxPercentage() << endl;
			str << "Current % " << tempValues->getPercentage() << endl;
			str << "Current Value " << tempValues->getValue() << endl;
			str << "Min " << tempValues->getMinValue() << " max " << tempValues->getMaxValue() << endl;
		}

		return str.toString();
	}
};

#endif /*VALUESCLASSES_H_*/
