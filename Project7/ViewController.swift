import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "credits", style: .plain , target: self, action: #selector(creditsTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterTapped))
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    self?.filteredPetitions = self!.petitions
                    return
                }
            }
            self?.showError()
        }
    }
    
    func showError() {
        
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    func parse(json: Data!) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredPetitions.isEmpty {
            return filteredPetitions.count
        } else {
            return petitions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        
        if !filteredPetitions.isEmpty {
            vc.detailItem = filteredPetitions[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            vc.detailItem = petitions[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func creditsTapped() {
        let ac = UIAlertController(title: "Credits", message: "Data Provided by 'We the People API' from the White House", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterTapped() {
        let ac = UIAlertController(title: "Search for:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let filterSubmit = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let termEntered = ac?.textFields?[0].text else { return }
            self?.submitFilterTerm(term: termEntered)
        }
        ac.addAction(filterSubmit)
        present(ac, animated: true)
    }
    
    func submitFilterTerm(term: String) {
        if term.isEmpty { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.filteredPetitions.removeAll(keepingCapacity: true)
            for petition in self.petitions {
                if petition.title.contains(term) {
                    self.filteredPetitions.append(petition)
                    DispatchQueue.main.async {
                    self.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "\(term) doesn't appear in list", message: "Please try another term", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        }
    }
}


