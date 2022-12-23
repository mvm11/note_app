//
//  NoteTableViewCell.swift
//  note_app
//
//  Created by Mateo Valencia on 22/12/22.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    

    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var noteDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
