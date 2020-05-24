//This class slightly modifies the functionality of https://github.com/GucioDevs/SimpleMinMaxSlider
//Credits go to GucioDevs, this is mostly to minimize package dependency and for me to learn how to make custom editors
//My Modifications are mostly for readability. One thing I changed in functionality is that instead of resetting to the range
//defined in the script, the range can be changed in the editor.

using System;
using UnityEngine;
using UnityEditor;
using MinMaxSlider;

[CustomPropertyDrawer(typeof(MinMaxSliderAttribute))]
public class MinMaxSliderDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        MinMaxSliderAttribute minMaxAttribute = (MinMaxSliderAttribute)attribute;
        SerializedPropertyType propertyType = property.propertyType;

        label.tooltip = minMaxAttribute.Min.ToString("F2") + "-" + minMaxAttribute.Max.ToString("F2");

        Rect controlRect = EditorGUI.PrefixLabel(position, label);

        Rect[] splitRect = SplitRect(controlRect);

        if (propertyType == SerializedPropertyType.Vector2)
        {
            EditorGUI.BeginChangeCheck();

            Vector2 range = property.vector2Value;
            float min = range.x;
            float max = range.y;

            min = EditorGUI.FloatField(splitRect[0], float.Parse(min.ToString("F2")));
            max = EditorGUI.FloatField(splitRect[2], float.Parse(max.ToString("F2")));

            EditorGUI.MinMaxSlider(splitRect[1], ref min, ref max, minMaxAttribute.Min, minMaxAttribute.Max);

            if (min < minMaxAttribute.Min)
            {
                minMaxAttribute.Min = min;
            }

            if (max > minMaxAttribute.Max)
            {
                minMaxAttribute.Max = max;
            };

            range = new Vector2(min > max ? max : min, max);

            if (EditorGUI.EndChangeCheck())
            {
                property.vector2Value = range;
            }
        }

        else if (propertyType == SerializedPropertyType.Vector2Int)
        {
            EditorGUI.BeginChangeCheck();

            Vector2Int range = property.vector2IntValue;
            float min = range.x;
            float max = range.y;

            min = EditorGUI.FloatField(splitRect[0], min);
            max = EditorGUI.FloatField(splitRect[2], max);

            EditorGUI.MinMaxSlider(splitRect[1], ref min, ref max, minMaxAttribute.Min, minMaxAttribute.Max);

            if (min < minMaxAttribute.Min)
            {
                minMaxAttribute.Min = min;
            }

            if (max > minMaxAttribute.Max)
            {
                minMaxAttribute.Max = max;
            };

            range = new Vector2Int(Mathf.FloorToInt(min > max ? max : min), Mathf.FloorToInt(max));

            if (EditorGUI.EndChangeCheck())
            {
                property.vector2IntValue = range;
            }
        }
    }

    Rect[] SplitRect(Rect rectToBeSplit)
    {
        int newRectAmount = 3;
        Rect[] newRects = new Rect[newRectAmount];

        foreach (var rect in newRects)
        {
            int rectIndex = Array.IndexOf(newRects, rect);
            newRects[rectIndex] = new Rect(rectToBeSplit.position.x + (rectIndex * rectToBeSplit.width / newRectAmount),
                                           rectToBeSplit.position.y,
                                           rectToBeSplit.width / newRectAmount,
                                           rectToBeSplit.height);
        }

        int padding = (int)newRects[0].width - 40;
        int space = 5;

        newRects[0].width -= padding + space;
        newRects[2].width -= padding + space;

        newRects[1].x -= padding;
        newRects[1].width += padding * 2;

        newRects[2].x += padding + space;

        return newRects;
    }
}