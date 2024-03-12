﻿using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Administrator : ISoftDeleted
{
    [Key]
    [Required]
    public long Id { get; set; }
    
    [ForeignKey("Creator")]
    public long? CreatorId { get; set; }

    [Required]
    public User User { get; set; }

    [Column(TypeName = "datetime")]
    public DateTime Joined { get; set; }
    
    public virtual Administrator Creator { get; set; }
    public bool IsDeleted { get; set; }
}
