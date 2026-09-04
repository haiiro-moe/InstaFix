package model

type ViewsData struct {
	Card        string
	Title       string `default:"Gakkou Instagram Club"`
	ImageURL    string `default:""`
	VideoURL    string `default:""`
	URL         string
	Description string
	OEmbedURL   string
	Width       int `default:"400"`
	Height      int `default:"400"`
}

type OEmbedData struct {
	Text string
	URL  string
}
