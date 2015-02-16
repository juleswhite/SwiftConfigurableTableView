/*
Copyright 2015 Jules White

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/*
This class provides a simplified mechanism for creating TableViewControllers.
Create the TableViewController in your storyboard and create a subclass of
ConfigurableTableViewController that is set as its type. You can optionally
use the provided ConfigurableTableViewCell for your cells and map prototype
cell UI elements to its various provided member variables (e.g., labelOne, etc.).
Using the ConfigurableTableViewCell is only for convenience to avoid having
to write UITableViewCell classes over and over. 

The ConfigurableTableViewController uses a fluent API and key/value mapping to
populate the TableView and provide sensible implementations of common methods.


Example usage:

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
*/

import UIKit
import Foundation

class TestData : NSObject {
    
    var foo:String;
    var bar:String;
    
    init(foo:String, bar:String) {
        self.foo = foo;
        self.bar = bar;
    }
    
}

class ConfigurableTableViewCell:UITableViewCell {
    @IBOutlet var labelOne:UILabel!;
    @IBOutlet var labelTwo:UILabel!;
    @IBOutlet var labelThree:UILabel!;
    @IBOutlet var labelFour:UILabel!;
    @IBOutlet var labelFive:UILabel!;
    @IBOutlet var textViewOne:UITextView!;
    @IBOutlet var textViewTwo:UITextView!;
    @IBOutlet var imageViewOne:UIImageView!;
    @IBOutlet var imageViewTwo:UIImageView!;
    @IBOutlet var imageViewThree:UIImageView!;
    @IBOutlet var buttonOne:UIButton!;
    @IBOutlet var buttonTwo:UIButton!;
}

class TableViewSection {
    
    var identifier:String = "CustomTableCell";
    var sectionTitle:String = "";
    var countFunc:()->Int = {return 0};
    
    var hideIfEmpty = true;
    var cellHeightEstimator:((index:Int)->Int) = {(i) in return 71};
    var headerHeightEstimator:((index:Int)->Int) = {(i) in return 100};
    
    var data:(()->[NSObject]) = {return []};
    var counter:(()->Int) = {return 0;};
    var selectionHandler:((index:Int)->()) = {(index) in };
    var itemGetter:((_:Int)->NSObject) = {(_) in return "";};
    var propertyMappings:[String:String] = [:];
    
    var viewCreator:((index:Int)->UITableViewCell) = {(index) in UITableViewCell(style:.Default, reuseIdentifier:"__default");};
    var viewConfigurer:((index:Int, theCell:UITableViewCell)->()) = {(_,_) in };
    var headerCreator:((title:String,tableView:UITableView)->UIView) = {(title:String,tableView:UITableView) in
        var view = UIView(frame:CGRectMake(0, 0, tableView.frame.size.width, 85));
        
        var label = UILabel(frame:CGRectMake(10, 8, tableView.frame.size.width - 10, 80));
        label.numberOfLines = 3;
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        label.textAlignment = NSTextAlignment.Left;
        
        label.textColor = UIColor(red:127/255.0, green:140/255.0, blue:141/255.0, alpha:1.0);
        label.font = UIFont(name:"HelveticaNeue", size:20);
        /* Section header is in 0th index... */
        label.text = title;
        view.addSubview(label);
        view.backgroundColor = UIColor.groupTableViewBackgroundColor();
        return view;
    };
    
    init(){
        
        self.counter = {return self.data().count};
        self.itemGetter = {(i) in return self.data()[i]};
        
        self.viewConfigurer = { (index:Int,theCell:UITableViewCell) in
            var item = self.item(index);
            
            for (k,v) in self.propertyMappings {
                var lbl:UILabel = theCell.valueForKey(k) as UILabel;
                
                var val = "";
                if(v == "self"){
                    val = "\(item)";
                } else {
                    val = "\(item.valueForKey(v)!)";
                }
                
                lbl.text = val;
            }
        };
        
    }
    
    func header(creator:((title:String,tableView:UITableView)->UIView)) -> TableViewSection{
        self.headerCreator = creator;
        return self;
    }
    
    func header(title:String,tableView:UITableView) -> UIView {
        return self.headerCreator(title: title, tableView: tableView);
    }
    
    func hideWhenEmpty() -> Bool {
        return self.hideIfEmpty;
    }
    
    func hideWhenEmpty(hide:Bool) -> TableViewSection {
        self.hideIfEmpty = hide;
        return self;
    }
    
    func data(data:[NSObject]) -> TableViewSection {
        self.data = {return data};
        return self;
    }
    
    func data(data:(()->[NSObject])) -> TableViewSection {
        self.data = data;
        return self;
    }
    
    func properties(props:[String:String]) -> TableViewSection{
        self.propertyMappings = props;
        return self;
    }
    
    func item(index:Int) -> NSObject {
        return self.itemGetter(index);
    }
    
    func cellIdentifier(id:String) -> TableViewSection {
        self.identifier = id;
        return self;
    }
    
    func cellIdentifier() -> String {
        return self.identifier;
    }
    
    func title(title:String) -> TableViewSection{
        self.sectionTitle = title;
        return self;
    }
    
    func title() -> String {
        return self.sectionTitle;
    }
    
    func cell(viewCreator:((index:Int)->UITableViewCell)) -> TableViewSection{
        self.viewCreator = viewCreator;
        return self;
    }
    
    func cell(index:Int) -> UITableViewCell {
        return self.viewCreator(index: index);
    }
    
    func configure(configurer:((index:Int, cell:UITableViewCell)->())) -> TableViewSection {
        self.viewConfigurer = configurer;
        return self;
    }
    
    func configure(index:Int, cell:UITableViewCell) {
        self.viewConfigurer(index: index, theCell: cell);
    }
    
    func count(counter:(()->Int)) -> TableViewSection{
        self.counter = counter;
        return self;
    }
    
    func count() -> Int{
        return self.counter();
    }
    
    func select(select:((index:Int)->())) -> TableViewSection{
        self.selectionHandler = select;
        return self;
    }
    
    func select(index:Int){
        self.selectionHandler(index: index);
    }
    
    func heightEstimation(estimator:((index:Int)->(Int))) -> TableViewSection{
        self.cellHeightEstimator = estimator;
        return self;
    }
    
    func heightEstimation(index:Int)->Int {
        return self.cellHeightEstimator(index: index);
    }
    
    func headerHeightEstimation(estimator:((index:Int)->(Int))) -> TableViewSection{
        self.headerHeightEstimator = estimator;
        return self;
    }
    
    func headerHeightEstimation(index:Int)->Int {
        return self.headerHeightEstimator(index: index);
    }
}

class ConfigurableTableViewController : UITableViewController {
    
    var sections:[TableViewSection] = [];
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
    }
    
    func section(section:TableViewSection) {
        self.sections.append(section);
    }
    
    func section() -> TableViewSection {
        var section = TableViewSection();
        self.section(section);
        return section;
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.sections[indexPath.section].select(indexPath.row);
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count();
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(self.sections[indexPath.section].heightEstimation(indexPath.row));
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.sections[section].title();
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection sectionNum: Int) -> CGFloat {
        var section = self.sections[sectionNum];
        if(section.count() == 0 && section.hideWhenEmpty()){
            return 0;
        }
        else {
            return CGFloat(section.headerHeightEstimation(sectionNum));
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var helper = self.sections[indexPath.section];
        var cellIdentifier = helper.cellIdentifier();
        var cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell?;
        
        // Configure the cell...
        if cell == nil {
            cell = helper.cell(indexPath.row);
        }
        
        helper.configure(indexPath.row, cell: cell!);
        
        return cell!;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.sections[section].title();
        return self.sections[section].header(title, tableView:tableView);
    }
    
}
