# Overview

This class provides a simplified mechanism for creating TableViewControllers.
Create the TableViewController in your storyboard and create a subclass of
ConfigurableTableViewController that is set as its type. You can optionally
use the provided ConfigurableTableViewCell for your cells and map prototype
cell UI elements to its various provided member variables (e.g., labelOne, etc.).
Using the ConfigurableTableViewCell is only for convenience to avoid having
to write UITableViewCell classes over and over. 

The ConfigurableTableViewController uses a fluent API and key/value mapping to
populate the TableView and provide sensible implementations of common methods.

# Example Usage

```java
class SomeController:ConfigurableTableViewController {

    override func viewDidLoad() {

        section()
            .title("Some Section Title") // Title for the section
            .data([TestData(foo: "a",bar: "b"), TestData(foo: "c",bar: "d")]) // Data to key/value map to UI
            .identifier("CustomTableCell") // ID (this is the default) of the TableCell
            .properties(["nameLabel":"foo"]) // how to map the data to the UI (e.g., map "foo" to the "nameLabel")
            .select({(index:Int) in }); // handle selection

        section()
            .title("Some Other Section Title")
            .data([TestData(foo: "a",bar: "b"), TestData(foo: "c",bar: "d")])
            .properties(["nameLabel":"foo"])
            .select({(index:Int) in });
    }
}
```

# Important Notes on Usage

1. If you want to use the automatic key/value mapping of your data objects to
   the UI, you must make the objects passed to .data([...]) inherit from NSObject
   otherwise key/value mapping will not work.

2. If you do not want to use key/value mapping, you can call the section().configure(...))
   function and provide a closure to manage the mapping of your data items to the
   UITableViewCell that was created. Example:
   
   ```java
           section()
            .title("I don't trust key/value mapping")
            .data([...])
            .configure({ (index,cell) in
                var myCell = cell as ConfigurableTableViewCell;
                myCell.labelOne.text = "Woohoo";
                myCell.labelTwo.text = "Wahhaaa";
            })
     ```
3. You can handle selection by passing a closure to the .select(...) function.
     ```java
           section()
            .title("Select Something")
            .data([...])
            .select({ (index) in
                var item = self.data[index];
                //do something!
            })
     ```

4. You can bind the data backing the TableView to a member variable like this.
     ```java
     class SomeController:ConfigurableTableViewController {
      var someData:[String] = [];
      
      override func viewDidLoad() {
           section()
            .title("Update the Table")
            .properties(["nameLabel":"self"])
            .data({self.someData}); //bind the data to a member variable
      }
      
      func updateData(){
          self.someData.append("foo");
          self.tableView.reloadData();
      }
    ```
5. If you have an array of Strings or other objects convertible to a String via "\\(item)",
   you can use "self" in the properties() call to refer to the object itself.
   
     ```java
     class SomeController:ConfigurableTableViewController {
      var someData:[String] = [];
      
      override func viewDidLoad() {
           section()
            .title("Update the Table")
            .properties(["nameLabel":"self"]) // Map the entire string value of the
                                              // item to the nameLabel
            .data({self.someData}); 
      }

    ```
    
5. The key value mapping is configured by the .properties([...]) method. The method
   expects a map that binds the names of member variables in your UITableViewCell
   subclass to member variables in your data class. You set the custom UITableViewCell
   class as normal in your prototype cells in the storyboard. You also set the identifier
   for each prototype cell in the storyboard and then match it up in your section declaration.
   
   Example:
   
    ```java
     class SomeController:ConfigurableTableViewController {
        var someData = [];
      
        override func viewDidLoad() {
           section()
            .title("Select Something")
            .identifier("MyTableCellIdentifier")
            .data([MyObj(name:"foo"),MyObj(name:"bar")]) 
            .properties([
              //Bind MyTableCell.nameLabel's text to MyObj.name
              "nameLabel":"name"
            ])
        }
      }
      
      class MyTableCell:UITableViewCell {
          @IBOutlet var nameLabel:UILabel!;
      }
      
      class MyObj:NSObject {
        var name:String;
        init(name:String){self.name=name;}
      }
      ```

6. If you don't want to write your on TableViewCell subclasses, you can
   simply reuse the ConfigurableTableViewCell class that is provided. In your
   storyboard, just map UI elements to the outlets for labels,
   image views, etc. in the ConfigurableTableViewCell class.
   
7. You can customize the creation of the UITableViewCells or the views for the
   section headers by providing a closure to construct each respectively.
   
   Example:
  ```java
     class SomeController:ConfigurableTableViewController {
        var someData = [];
      
        override func viewDidLoad() {
           section()
            .title("Select Something")
            .data([])
            .header({ (title:String,tableView:UITableView)->UIView) in
               var myHeader = ...; // Create your custom section header
               // configure stuff
               return myHeader;
            })
            .cell({(index:Int)->UITableViewCell) in
               var myCell = ...; // Create or dequeue your cell
               // configure stuff
               return myCell;
            });
        
        }
      }
  ```
  
7. Most things can be configured. Take a look at the source to find the appropriate 
   method to override the defaults provided by the ConfigurableTableViewCell.
   
# Common Errors

_"this class is not key value coding-compliant for the key"_ - If you see this or a similar error,
it is most likely caused by:

1. One or more of the mappings passed into .properties(["memberVariableOnUITableCellClass":"memberVariableOnDataItem",..])
   is wrong. Either the member variable in the UITableCellClass doesn't exist or the member variable on your
   data item doesn't exist.
2. Possibly, you somehow provided data items that don't inherit from NSObject.
3. You might accidentally be using (or have not specified) a table cell identifier that returns a UITableCell that
   isn't the class that you are expecting.
