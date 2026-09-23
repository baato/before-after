package api

import (
	"io"
	"net/http"
	"regexp"
	"sort"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

type cachedDates struct {
	dates []string
	at    time.Time
}

var dateCache = struct {
	sync.RWMutex
	m map[string]cachedDates
}{m: map[string]cachedDates{}}

var pbfDateRe = regexp.MustCompile(`-(\d{6})\.osm\.pbf`)
var safeName = regexp.MustCompile(`^[a-z0-9-]+$`)

// AvailableDatesAPI returns the dates Geofabrik actually publishes a dated
// extract for, for a given region — so the UI can restrict the date pickers to
// downloadable dates only. Response: {"dates": ["2026-09-01", ...]} (newest first).
func (server *Server) AvailableDatesAPI(ctx *gin.Context) {
	continent := ctx.Query("continent")
	country := ctx.Query("country")
	if !safeName.MatchString(continent) || !safeName.MatchString(country) {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "continent and country required"})
		return
	}

	key := continent + "/" + country
	dateCache.RLock()
	if c, ok := dateCache.m[key]; ok && time.Since(c.at) < time.Hour {
		dateCache.RUnlock()
		ctx.JSON(http.StatusOK, gin.H{"dates": c.dates})
		return
	}
	dateCache.RUnlock()

	url := "https://download.geofabrik.de/" + continent + "/" + country + ".html"
	client := http.Client{Timeout: 20 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		ctx.JSON(http.StatusBadGateway, gin.H{"error": "could not reach Geofabrik", "dates": []string{}})
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		ctx.JSON(http.StatusOK, gin.H{"dates": []string{}})
		return
	}
	body, _ := io.ReadAll(io.LimitReader(resp.Body, 8<<20))

	seen := map[string]bool{}
	dates := []string{}
	for _, m := range pbfDateRe.FindAllStringSubmatch(string(body), -1) {
		y := m[1]
		d := "20" + y[0:2] + "-" + y[2:4] + "-" + y[4:6]
		if !seen[d] {
			seen[d] = true
			dates = append(dates, d)
		}
	}
	sort.Sort(sort.Reverse(sort.StringSlice(dates)))

	dateCache.Lock()
	dateCache.m[key] = cachedDates{dates: dates, at: time.Now()}
	dateCache.Unlock()

	ctx.JSON(http.StatusOK, gin.H{"dates": dates})
}
