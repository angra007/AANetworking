# AANetworking

AANetworking is a network framework written in Swift 2.2. The original idea of the design was inspired by a talk on https://www.objc.io/. The design has been furter extended to use Operation Queue, Caching, Image Download.

# Using it in your project
1. Create a Resource.
    
  ```Swift
  class func movieResource () -> Resource<[Movie]> 
  {
        let type : OperationType = .topRated
        let resource = Resource<[Movie]>(urlString: type.url ,operationType : type, parse: { data in
            // Parse your model object here and return parsed object
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            guard let dictionaries = json as? [String:AnyObject] else { return nil }
            guard let results : [AnyObject] = dictionaries["results"] as? [AnyObject] else { return nil }
            return results.flatMap() {
                Movie.init(movieDetails: $0 as! JSONDictionary)
            }
        })
        return resource
    }
    ```
2. Pass that resource to load() of WebServiceOperation class. In the Completion Handler you will either get data or error.
  ```Swift
  WebServiceOperation.instantiate().loadMedia(resource) { (data, error) in
            
            guard let image = (data as? UIImage) else {
                // Display Some Error
                return }
            Spinner.sharedInstance.hideSpinner(inView : self)
            self.image = image
        }
  ```
3. Saving in Caching 
```Swift
  let cache = Cache (type :.Asserts)
  cache.store(data, forURL: url, timestamp: modificationDate)
```
4. Retriving from Cache
```Swift
  if let data = cache.data(forURL: resource.urlString, timestamp: resource.modificationDate) {
      // You have a Cached data 
  }
```
# ToDo
1. Improving the design
2. HTML Parsing Support
3. Handling dependenies in web request
4. Handling POST request
5. Handling No Network




