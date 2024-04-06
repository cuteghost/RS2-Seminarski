using System.Reflection;

namespace Services.PropertyService;

public interface IPropertyService
{
    public string GetPropertyName(PropertyInfo propertyInfo);
    public string GetPropertyValue(PropertyInfo propertyInfo,object myObject);
    public int GetMaxLengthOfTheFieldBasedOnAttributte(PropertyInfo propertyInfo);
    public int GetMinLengthOfTheFieldBasedOnAttributte(PropertyInfo propertyInfo);
   
}