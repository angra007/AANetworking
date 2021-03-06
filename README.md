# AANetworking

AANetworking is a concept for a very light weight network framework. It supports GET and POST requests with public, private key encryption, exponential backoff, SSL certificate validation etc.  

# Using it in your project

Initilize your public key at
```
Swift WebServiceManager.sharedManager.pKey
``` 
To send a request create a file similar to ```NetworkHelper.swift```

Data is extracted in  ```WebServiceOperation``` to be saved in model. Change implementation of  ```handleDownloadCompletion  ``` according to extract data and status from your response. 

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
5. <del> Handling No Network </del>
6. Handling XML request
7. Handling Image request
8. <del> Handling Multipart Request </del>


# License


Copyright (c) 2011-2016 Ankit Angra.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





