
# Not installed by default
# pip3 install --user --upgrade pip
# pip3 install --user Pillow
from PIL import Image

# Not installed by default
# pip3 install --user scipy
from scipy.signal import convolve2d

from tqdm import tqdm # Not installed by default
import numpy as np # Not installed by default

# # Test image generation
# images=[]
# for i in range(0,255):
#     arr = np.ones((500, 500, 3), dtype=np.uint8)
#     arr[:, :, 1] = i
#     images.append(Image.fromarray(arr))

# images_itr = iter(images)
# img = next(images_itr)
# img.save('output_video.gif', format='GIF', append_images=images_itr, 
#         save_all=True, duration=2, loop=0)


''' CGOL truth table
Neighbors: 2 3 other
Alive      A A D
Dead       D A D
'''

def cgol_iter(arr: np.ndarray) -> np.ndarray:
    # print('next game step...')
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_next = np.zeros((X, Y), dtype=np.uint8)
    for x in range(X):
        for y in range(Y):
            ngh = arr[max(0, x-1):min(X, x+2), max(0, y-1):min(Y, y+2)].sum()
            if arr[x,y]:
                ngh -= 1
                if ngh in (2, 3): arr_next[x, y] = 1
            else:
                if ngh == 3: arr_next[x, y] = 1
    # print('done')
    return arr_next

def cgol_iter2(arr: np.ndarray) -> np.ndarray:
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_next = np.zeros((X, Y), dtype=np.uint8)
    x_min = max(np.argwhere(arr)[:,0].min()-2, 0)
    x_max = min(np.argwhere(arr)[:,0].max()+2, X)
    y_min = max(np.argwhere(arr)[:,1].min()-2, 0)
    y_max = min(np.argwhere(arr)[:,1].max()+2, Y)
    
    for x in range(x_min, x_max):
        for y in range(y_min, y_max):
            # 8 single-element reads instead
            ngh = 0
            if x > 0   and y > 0  : ngh += arr[x-1, y-1] # TL
            if             y > 0  : ngh += arr[x  , y-1] # T
            if x < X-1 and y > 0  : ngh += arr[x+1, y-1] # TR
            if x > 0              : ngh += arr[x-1, y  ] # L
            if x < X-1            : ngh += arr[x+1, y  ] # R
            if x > 0   and y < Y-1: ngh += arr[x-1, y+1] # BL
            if             y < Y-1: ngh += arr[x  , y+1] # B
            if x < X-1 and y < Y-1: ngh += arr[x+1, y+1] # BR

            if arr[x,y]:
                if ngh in (2, 3): arr_next[x, y] = 1 # Stay alive
            else:
                if ngh == 3:      arr_next[x, y] = 1 # Become alive
    return arr_next

def cgol_iter3(arr: np.ndarray) -> np.ndarray:    
    # Perform 'num-neighbors' convolution
    ngh_window = np.array([[1,1,1],[1,0,1],[1,1,1]])
    ngh_arr = convolve2d(arr, ngh_window, mode='same', boundary='fill', fillvalue=0)
    # Generate next CGOL generation with the formula: "arr_next = (3nghs OR (arr AND 2nghs))"
    return np.logical_or((ngh_arr==3), np.logical_and(arr, (ngh_arr==2))).astype(np.uint8)

# def board_to_img(arr: np.ndarray, px_size: int) -> Image:
#     print('converting to image...')
#     X = arr.shape[0]
#     Y = arr.shape[1]
#     arr_img = np.empty((X*px_size, Y*px_size, 3), dtype=np.uint8)
#     for c in (0,1,2): arr_img[:, :, c] = dead_color[c]
#     for x in range(X):
#         for y in range(Y):
#             if arr[x,y]:
#                 x_start = px_size*x
#                 y_start = px_size*y
#                 arr_img[x_start:x_start+px_size, 
#                         y_start:y_start+px_size, :] = alive_color
#     print('done')
#     return Image.fromarray(arr_img)

def board_to_img2(arr: np.ndarray, px_size: int, a:tuple=(255,255,255), d:tuple=(0,0,0)) -> Image:
    # print('converting to image...')
    X = arr.shape[0]
    Y = arr.shape[1]
    arr_img = np.empty((X*px_size, Y*px_size, 3), dtype=np.uint8)
    # Repeat matrix to size of board
    arr_rep = arr.repeat(px_size, 0).repeat(px_size, 1)
    # For each channel, set alive or dead value based on arr_rep
    for c in (0,1,2): arr_img[:, :, c] = arr_rep*(a[c]-d[c]) + d[c]
    im = Image.fromarray(arr_img)
    # print('done')
    return im

def save_gif(images: list, fname: str, frame_dur:int=50) -> None:
    print('Saving GIF... ', end='', flush=True) 
    # images_itr = iter(images)
    # img = next(images_itr)
    # Note: set loop=1 to generate GIFs that play once
    images[0].save(fname, format='GIF', append_images=images[1:], 
            save_all=True, duration=frame_dur, loop=0, optimize=False)
    print('done.')








def main():
    vid_out_fname = 'cgol.gif'
    board_x = 128 #512
    board_y = 128 #512
    game_length = 800 # 2300

    dead_color   = (128, 128, 128)
    alive_color  = (  0, 255,   0)
    grid_px_size = 4

    # 'Glider'
    # board_init = np.zeros((board_y, board_x), dtype=np.uint8)
    # board_init[5,6] = 1
    # board_init[6,7] = 1
    # board_init[7,5:8] = 1

    # # 'Spaceship'
    # board_x = 16
    # board_y = 256
    # game_length = 550
    # board_init = np.zeros((board_y, board_x), dtype=np.uint8)
    # board_init[2, 7] = 1
    # board_init[2, 9] = 1
    # board_init[5, 9] = 1
    # board_init[3:7, 6] = 1
    # board_init[6, 6:9] = 1
    # board_init = board_init.transpose()

    # 'Acorn' (Goes about 5300)
    board_init = np.zeros((board_y, board_x), dtype=np.uint8)
    mid = (board_x//2, board_y//2)
    board_init[mid[0]-2, mid[1]-1]=1
    board_init[mid[0], mid[1]]=1
    board_init[mid[0]-3:mid[0]-1, mid[1]+1]=1
    board_init[mid[0]+1:mid[0]+4, mid[1]+1]=1
    board_init = board_init.transpose()

    images = []
    board = board_init
    print('Generating game...')
    for i in tqdm(range(game_length), disable=False):
        images.append(board_to_img2(board, grid_px_size, a=alive_color, d=dead_color))
        board = cgol_iter3(board)

    # Save animated GIF
    save_gif(images, vid_out_fname, frame_dur=35)
    # Save initial setup of the board
    # init_img = board_to_img2(board_init, grid_px_size, a=alive_color, d=dead_color)
    images[0].save('cgol_init.gif', format='GIF', save_all=True)

if __name__ == '__main__':
    main()
