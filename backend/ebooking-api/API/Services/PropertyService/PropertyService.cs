using System.ComponentModel.DataAnnotations;
using System.Reflection;

namespace Services.PropertyService;

public class PropertyService : IPropertyService
{
    public PropertyService()
    {
        
    }
    public string GetPropertyName(PropertyInfo propertyInfo)
    {
        if(propertyInfo.Name != null) return propertyInfo.Name.ToString();
        return "";
    }
    public string GetPropertyValue(PropertyInfo propertyInfo,object myObject)
    {
        try
        {
            if (propertyInfo.GetValue(myObject) != null) return  propertyInfo.GetValue(myObject).ToString();    
        }
        catch(Exception ex)
        {
            Console.WriteLine($"Exception: {ex.ToString()}");
        }
        return "";
    }
    public int GetMaxLengthOfTheFieldBasedOnAttributte(PropertyInfo propertyInfo)
    {
        try
        {
            var props = propertyInfo.GetCustomAttributes(typeof(MaxLengthAttribute), true);
            if (props != null && (MaxLengthAttribute)props[0] != null)
            {
                System.ComponentModel.DataAnnotations.MaxLengthAttribute maxLengthAttr = (MaxLengthAttribute)props[0];
                return maxLengthAttr.Length;
            }
        }
        catch(Exception ex)
        {
            Console.WriteLine($"Exception: {ex.ToString()}");
        }
        return 0;
    }
    public int GetMinLengthOfTheFieldBasedOnAttributte(PropertyInfo propertyInfo)
    {
        try
        {
            var props = propertyInfo.GetCustomAttributes(typeof(MinLengthAttribute), true);
            if (props != null && (MinLengthAttribute)props[0] != null)
            {
                System.ComponentModel.DataAnnotations.MinLengthAttribute minLengthAttr = (MinLengthAttribute)props[0];
                return minLengthAttr.Length;
            }
        }
        catch(Exception ex)
        {
            Console.WriteLine($"Exception: {ex.ToString()}");
        }
        return 0;
    }
}