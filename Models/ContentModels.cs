namespace MedTrueApi.Models;

public class Banner
{
    public long Id { get; set; } // Maps to banner_id
    public string Title { get; set; } = string.Empty;
    public string? Slug { get; set; } // Optional/Nullable in code, handle DB
    public string? CustomUrl { get; set; }
    
    public string Type { get; set; } = "custom";
    public string ScopeType { get; set; } = "global";
    public long? ScopeId { get; set; }
    
    public long? ProductId { get; set; }
    public long? CategoryId { get; set; }
    public long? BrandId { get; set; }
    
    public string Position { get; set; } = "top";
    public bool IsActive { get; set; } = true; // Maps to is_active
    
    public int DisplayOrder { get; set; } = 0;
    public string? Metadata { get; set; }
    
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    
    public string? ImagePath { get; set; }
}

public class FeaturedSection
{
    public long Id { get; set; } // Maps to section_id
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? ShortDescription { get; set; }
    
    public string ScopeType { get; set; } = "global";
    public long? ScopeId { get; set; }
    
    public string SectionType { get; set; } = string.Empty; // newly_added, etc.
    public string Style { get; set; } = "default";
    
    // Appearance
    public string? BackgroundType { get; set; } // image, color
    public string? BackgroundColor { get; set; }
    public string TextColor { get; set; } = "#000000";
    
    public bool IsActive { get; set; } = true; // Maps to is_active
    public int SortOrder { get; set; } = 0;
    
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
