# AANetworking

AANetworking is a network framework written in Swift 3. The original idea of the design was inspired by a talk on https://www.objc.io/. However, the design has been simplified and extended to and to implement POST Request, Multipart, AES256 and a lot more.

# Using it in your project
If you need session and AES256 in your app, pass your cookies to 
```
Swift WebServiceManager.sharedManager.cookie
``` 
and pKey to 
```
Swift WebServiceManager.sharedManager.pKey
``` 
To send a request create a file similar to NetworkHelper.swift.d
d
Extract the data  ```WebServiceOperation``` to be saved in model in. Change implementation of  ```handleDownloadCompletion  ``` according to your response keys to extract data and status. 

Example of Usage: 
  ```Swift
   NetworkHelper.load(url: "url", parse: { (dict) -> AnyObject? in
            // This is your parser. Return modeled data from here
            
            return dict as? AnyObject
        }) { (data, error) in
            
            // This is your completion handler
        }
  ```

# ToDo
1. Improving the design
2. HTML Parsing Support
3. Handling dependenies in web request
4. <del> Handling POST request </del>
5. Handling No Network
6. Handling XML request
7. Handling Image request
8. <del> Handling Multipart Request </del>


# License


Copyright (c) 2011-2016 Ankit Angra.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





