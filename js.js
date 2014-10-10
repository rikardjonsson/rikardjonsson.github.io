// Convert JSON object to query string for AJAX call
function toQueryString(obj) {
    parts = [];
    for (i in obj) {
        parts.push(encodeURIComponent(i) + "=" + encodeURIComponent(obj[i]));
    }
    return parts.join("&");
}

// Namespace for Spotify API methods
var spotify = {
    endpoint: 'https://api.spotify.com/v1',

    // Search artists by name (https://developer.spotify.com/web-api/console/get-search-item/)
    searchArtist: function(artist) {
        var params = {
            type: 'artist',
            q: artist
        };

        var results = '';
        $.ajax({
            url: spotify.endpoint + "/search?" + toQueryString(params),
            async: false,
            success: function(response) {
                results = response;
            }
        }); 
        return results;
    },

    // Make a playlist URL from an array of song IDs (https://developer.spotify.com/technologies/widgets/spotify-play-button/)
    getPlaylistURL: function(songIds) {
        var url = 'https://embed.spotify.com/?uri=spotify:trackset:Music!:';
        return url + songIds.join(",");
    }
};

// Namespace for Echonest API methods
var echonest = {
    endpoint: 'http://developer.echonest.com/api/v4',
    api_key: '220NH6KN54BGR3ZJU',

    // Get genres by artist id (http://developer.echonest.com/docs/v4/artist.html)
    getArtistGenres: function(artistId) {
        var params = {
            api_key: echonest.api_key,
            bucket: 'genre',
            format: 'json',
            id: 'spotify:artist:' + artistId
        };
        var results = '';
        $.ajax({
            url: echonest.endpoint + "/artist/profile?" + toQueryString(params),
            async: false,
            success: function(response) {
                results = response;
            }
        });
        return results;
    },

     // Get a playlist by an array of genres using (http://developer.echonest.com/docs/v4/standard.html#static)
    getPlaylistByGenres: function(genres) {
        var params = {
            api_key: echonest.api_key,
            format: 'json',
            results: '85',
            type: 'genre-radio',
        };
        var queryString = toQueryString(params);

        // Here be function to figure out which genres the user uses the most

        // Limit genres to 5, the max no of genres for genre-radio
        genres = genres.slice(0,5);

        // Add genres to query string
        for (i in genres) {
            queryString = queryString + "&genre=" + encodeURIComponent(genres[i]) + "&bucket=tracks&bucket=" + encodeURIComponent("id:spotify-WW");
        }

        var results = '';
        $.ajax({
            url: echonest.endpoint + "/playlist/static?" + queryString,
            async: false,
            success: function(response) {
                results = response;
            }
        });
        return results;
    }
};

// Search the Spotify API by an array artist names, return the ID of the first result for each name (https://developer.spotify.com/web-api/console/get-search-item/)
function getArtistIds(artists) {
    var artistIds = [];
    for (i=0; i<artists.length; i++) {
        var artistData = spotify.searchArtist(artists[i]);
        if (artistData.artists.items.length > 0) {
            artistIds.push(artistData.artists.items[0].id);
        }
    }
    return artistIds;
    
}

// Get genres from Echonest by an array of artist IDs, return genre names (http://developer.echonest.com/docs/v4/artist.html)
function getGenres(artistIds) {
    var genres = [];
    for (i in artistIds) {
        var genreData = echonest.getArtistGenres(artistIds[i]);
        for (g in genreData.response.artist.genres) {
            genres.push(genreData.response.artist.genres[g].name);
        }
    }
    return genres;
}

// Get Echonest playlist from an array of genres and return the Spotify song IDs  (http://developer.echonest.com/docs/v4/standard.html#static)
function getPlaylist(genres) {
    var playlist = echonest.getPlaylistByGenres(genres);
    var songIds = [];
    var songs = playlist.response.songs;
    for (i=0; i<songs.length; i++) {
        if (songs[i].tracks.length) {
            var songId = songs[i].tracks[0].foreign_id;
            songId = songId.replace(/spotify:track:/, '');
            songIds.push(songId);
        }
    }
    return songIds;
}

$(document).ready(function() {
    $("#search-form").submit(function (event) {
        event.preventDefault();
        var artists = $("#artist-input").val();
        if (artists != "") {
            artists = artists.split(/,\s*/);

            var artistIds = getArtistIds(artists);
            var genres = getGenres(artistIds);
            var songIds = getPlaylist(genres);

            // Create Spotify widget
            var playlist = document.createElement("IFRAME");
            playlist.setAttribute('margin', "auto");
            playlist.setAttribute('frameborder', 0);
            playlist.setAttribute('allowtransparency', true);
            playlist.setAttribute('Height', 400);
            playlist.setAttribute('Width', 600);
            playlist.setAttribute('src', spotify.getPlaylistURL(songIds))
            
            // Reset playlist-container with every search, add new player 
            $("#playlist-container").html("");
            $("#playlist-container").append(playlist);
            
            // Display genres in the playlist
            genres = genres.slice(0,5);
            $("#genre-container").html(genres.join(", "));


        }
    });
});

